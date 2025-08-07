package ongi.temperature.service;

import lombok.RequiredArgsConstructor;
import ongi.exception.EntityNotFoundException;
import ongi.family.repository.FamilyRepository;
import ongi.temperature.dto.FamilyTemperatureResponse;
import ongi.temperature.dto.FamilyTemperatureDailyResponse;
import ongi.temperature.dto.FamilyTemperatureContributionResponse;
import ongi.temperature.entity.Temperature;
import ongi.temperature.repository.TemperatureRepository;
import ongi.user.entity.User;
import ongi.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.scheduling.annotation.Scheduled;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class TemperatureService {
    private final TemperatureRepository temperatureRepository;
    private final FamilyRepository familyRepository;
    private final UserRepository userRepository;
    private static final double BASE_TEMPERATURE = 36.5;

    // 소수점 1자리 반올림 유틸
    private static double round(double value, int places) {
        if (places < 0) throw new IllegalArgumentException();
        BigDecimal bd = BigDecimal.valueOf(value);
        bd = bd.setScale(places, RoundingMode.HALF_UP);
        return bd.doubleValue();
    }

    //// 가족 온도 그래프 및 기여도 조회
    public FamilyTemperatureResponse getFamilyTemperatureSummary(String familyId) {

        familyRepository.findById(familyId)
                .orElseThrow(() -> new EntityNotFoundException("가족을 찾을 수 없습니다."));

        // 가족의 모든 온도 기록 조회
        List<Temperature> temperatures = temperatureRepository.findByFamilyId(familyId);

        // 가족 전체 온도 기여 합계
        Double totalContributedTemperature = temperatureRepository.getTotalTemperatureByFamilyId(familyId);
        double contributedSum = totalContributedTemperature != null ? totalContributedTemperature : 0.0;

        // 가족 온도 = 기본값 + 전체 기여 합
        double familyTemperature = BASE_TEMPERATURE + contributedSum;

        // userId별로 온도 기여 합계 집계
        Map<UUID, Double> userTemperatures = temperatures.stream()
                .collect(Collectors.groupingBy(
                        Temperature::getUserId,
                        Collectors.summingDouble(Temperature::getTemperature)
                ));

        // userId로 실제 유저 정보 조회
        List<UUID> userIds = new ArrayList<>(userTemperatures.keySet());
        Map<UUID, User> users = userRepository.findAllById(userIds).stream()
                .collect(Collectors.toMap(User::getUuid, user -> user));

        // 각 구성원별 기여도 및 퍼센트 계산
        List<FamilyTemperatureResponse.MemberTemperatureInfo> memberTemperatures = userTemperatures.entrySet().stream()
                .map(entry -> {
                    UUID userId = entry.getKey();
                    Double contributedTemperature = entry.getValue();
                    User user = users.get(userId);
                    // 전체 기여 합이 0일 때는 0%, 아니면 비율 계산
                    double percentage = contributedSum > 0 ? (contributedTemperature / contributedSum) * 100 : 0.0;
                    percentage = BigDecimal.valueOf(percentage).setScale(2, RoundingMode.HALF_UP).doubleValue();
                    return FamilyTemperatureResponse.MemberTemperatureInfo.builder()
                            .userId(userId)
                            .userName(user != null ? user.getName() : "")
                            .contributedTemperature(round(contributedTemperature, 1))
                            .percentage(round(percentage, 2))
                            .build();
                })
                .collect(Collectors.toList());

        return FamilyTemperatureResponse.builder()
                .familyTemperature(round(familyTemperature, 1))
                .totalContributedTemperature(round(contributedSum, 1))
                .memberTemperatures(memberTemperatures)
                .build();
    }

    //// 최근 5일간 가족 온도 총합 조회
    public FamilyTemperatureDailyResponse getFamilyTemperatureDaily(String familyId) {
        familyRepository.findById(familyId)
                .orElseThrow(() -> new EntityNotFoundException("가족을 찾을 수 없습니다."));
        java.time.LocalDateTime fromDate = java.time.LocalDate.now().minusDays(4).atStartOfDay(); // 최근 5일
        List<Object[]> rawList = temperatureRepository.getFamilyTemperatureDailyRaw(familyId, fromDate);
        // 날짜별 변화량 맵 (오름차순)
        Map<LocalDate, Double> dateToDelta = new TreeMap<>();
        for (Object[] arr : rawList) {
            LocalDate date = ((java.sql.Date) arr[0]).toLocalDate();
            Double delta = (Double) arr[1];
            dateToDelta.put(date, delta);
        }
        // 누적 합산
        double base = 36.5;
        double sum = base;
        List<FamilyTemperatureDailyResponse.DailyTemperature> dailyList = new ArrayList<>();
        for (Map.Entry<LocalDate, Double> entry : dateToDelta.entrySet()) {
            sum += entry.getValue();
            dailyList.add(new FamilyTemperatureDailyResponse.DailyTemperature(entry.getKey(), round(sum, 1)));
        }
        return new FamilyTemperatureDailyResponse(dailyList);
    }

    //// 최근 5일간 가족 구성원별 온도 기여 내역 조회
    public FamilyTemperatureContributionResponse getFamilyTemperatureContributions(String familyId) {
        familyRepository.findById(familyId)
                .orElseThrow(() -> new EntityNotFoundException("가족을 찾을 수 없습니다."));
        java.time.LocalDateTime fromDate = java.time.LocalDate.now().minusDays(4).atStartOfDay(); // 최근 5일
        List<Object[]> rawList = temperatureRepository.getFamilyTemperatureContributionsRaw(familyId, fromDate);

        Set<UUID> userIds = rawList.stream()
                .map(arr -> (UUID) arr[1])
                .collect(Collectors.toSet());
        Map<UUID, User> userMap = userRepository.findAllById(userIds).stream()
                .collect(Collectors.toMap(User::getUuid, user -> user));

        List<FamilyTemperatureContributionResponse.Contribution> contributions = rawList.stream()
                .map(arr -> {
                    LocalDate date = ((java.sql.Date) arr[0]).toLocalDate();
                    UUID userId = (UUID) arr[1];
                    Double contributed = (Double) arr[2];
                    String userName;
                    if (userId == null) {
                        userName = "우리 가족";
                    } else {
                        userName = userMap.get(userId) != null ? userMap.get(userId).getName() : "";
                    }
                    return new FamilyTemperatureContributionResponse.Contribution(date, userName, round(contributed, 1));
                })
                .toList();
        return new FamilyTemperatureContributionResponse(contributions);
    }




    //// 온도 상승 메서드

    // 활동별 reason 상수 정의
    private static final String REASON_EMOTION_UPLOAD = "EMOTION_UPLOAD";
    private static final String REASON_ALL_EMOTION_UPLOAD = "ALL_EMOTION_UPLOAD";
    private static final String REASON_STEP_GOAL = "STEP_GOAL";
    private static final String REASON_PARENT_PAIN_INPUT = "PARENT_PAIN_INPUT";
    private static final String REASON_PARENT_MED_INPUT = "PARENT_MED_INPUT";
    private static final String REASON_PARENT_EXERCISE_INPUT = "PARENT_EXERCISE_INPUT";
    private static final String REASON_CHILD_PAIN_VIEW = "CHILD_PAIN_VIEW";
    private static final String REASON_CHILD_MED_VIEW = "CHILD_MED_VIEW";
    private static final String REASON_CHILD_EXERCISE_VIEW = "CHILD_EXERCISE_VIEW";

    private java.time.LocalDate getToday() {
        return java.time.LocalDate.now();
    }

    // 감정기록 업로드 시 온도 상승 (하루 1회만 적용)
    public void increaseTemperatureForEmotionUpload(UUID userId, String familyId) {
        java.time.LocalDate today = getToday();
        boolean alreadyIncreased = temperatureRepository.existsByUserIdAndFamilyIdAndReasonAndDate(userId, familyId, REASON_EMOTION_UPLOAD, today);
        if (!alreadyIncreased) {
            Temperature temp = Temperature.builder()
                    .userId(userId)
                    .familyId(familyId)
                    .temperature(0.1)
                    .reason(REASON_EMOTION_UPLOAD)
                    .build();
            temperatureRepository.save(temp);
        }
    }

    // 부모 통증 부위 입력 오늘 1회만 온도 상승
    public void increaseTemperatureForParentPainInput(UUID userId, String familyId) {
        java.time.LocalDate today = getToday();
        boolean already = temperatureRepository.existsByUserIdAndFamilyIdAndReasonAndDate(userId, familyId, REASON_PARENT_PAIN_INPUT, today);
        if (!already) {
            Temperature temp = Temperature.builder()
                    .userId(userId)
                    .familyId(familyId)
                    .temperature(0.1)
                    .reason(REASON_PARENT_PAIN_INPUT)
                    .build();
            temperatureRepository.save(temp);
        }
    }
    // 부모 약 복용 입력 오늘 1회만 온도 상승
    public void increaseTemperatureForParentMedInput(UUID userId, String familyId) {
        java.time.LocalDate today = getToday();
        boolean already = temperatureRepository.existsByUserIdAndFamilyIdAndReasonAndDate(userId, familyId, REASON_PARENT_MED_INPUT, today);
        if (!already) {
            Temperature temp = Temperature.builder()
                    .userId(userId)
                    .familyId(familyId)
                    .temperature(0.1)
                    .reason(REASON_PARENT_MED_INPUT)
                    .build();
            temperatureRepository.save(temp);
        }
    }
    // 부모 운동 시간 입력 오늘 1회만 온도 상승
    public void increaseTemperatureForParentExerciseInput(UUID userId, String familyId) {
        java.time.LocalDate today = getToday();
        boolean already = temperatureRepository.existsByUserIdAndFamilyIdAndReasonAndDate(userId, familyId, REASON_PARENT_EXERCISE_INPUT, today);
        if (!already) {
            Temperature temp = Temperature.builder()
                    .userId(userId)
                    .familyId(familyId)
                    .temperature(0.1)
                    .reason(REASON_PARENT_EXERCISE_INPUT)
                    .build();
            temperatureRepository.save(temp);
        }
    }
    // 자녀 통증 부위 확인 오늘 1회만 온도 상승
    public void increaseTemperatureForChildPainView(UUID userId, String familyId) {
        java.time.LocalDate today = getToday();
        boolean already = temperatureRepository.existsByUserIdAndFamilyIdAndReasonAndDate(userId, familyId, REASON_CHILD_PAIN_VIEW, today);
        if (!already) {
            Temperature temp = Temperature.builder()
                    .userId(userId)
                    .familyId(familyId)
                    .temperature(0.1)
                    .reason(REASON_CHILD_PAIN_VIEW)
                    .build();
            temperatureRepository.save(temp);
        }
    }
    // 자녀 약 복용 확인 오늘 1회만 온도 상승
    public void increaseTemperatureForChildMedView(UUID userId, String familyId) {
        java.time.LocalDate today = getToday();
        boolean already = temperatureRepository.existsByUserIdAndFamilyIdAndReasonAndDate(userId, familyId, REASON_CHILD_MED_VIEW, today);
        if (!already) {
            Temperature temp = Temperature.builder()
                    .userId(userId)
                    .familyId(familyId)
                    .temperature(0.1)
                    .reason(REASON_CHILD_MED_VIEW)
                    .build();
            temperatureRepository.save(temp);
        }
    }
    // 자녀 운동 시간 확인 오늘 1회만 온도 상승
    public void increaseTemperatureForChildExerciseView(UUID userId, String familyId) {
        java.time.LocalDate today = getToday();
        boolean already = temperatureRepository.existsByUserIdAndFamilyIdAndReasonAndDate(userId, familyId, REASON_CHILD_EXERCISE_VIEW, today);
        if (!already) {
            Temperature temp = Temperature.builder()
                    .userId(userId)
                    .familyId(familyId)
                    .temperature(0.1)
                    .reason(REASON_CHILD_EXERCISE_VIEW)
                    .build();
            temperatureRepository.save(temp);
        }
    }


    // 매일 23:59:59에 당일의 가족별 보너스 온도 상승 처리
    @Scheduled(cron = "59 59 23 * * *")
    @Transactional
    public void processFamilyBonusTemperature() {
        var families = familyRepository.findAll();
        java.time.LocalDate targetDate = getToday(); // 오늘 날짜
        for (var family : families) {
            String familyId = family.getCode();
            var members = family.getMembers();

            // 전체 가족 구성원이 감정기록 업로드 시 보너스
            boolean allEmotionUploaded = members.stream().allMatch(
                    userId -> temperatureRepository.existsByUserIdAndFamilyIdAndReasonAndDate(userId, familyId, REASON_EMOTION_UPLOAD, targetDate)
            );
            boolean alreadyEmotionBonus = temperatureRepository.existsByUserIdAndFamilyIdAndReasonAndDate(null, familyId, REASON_ALL_EMOTION_UPLOAD, targetDate);
            if (allEmotionUploaded && !alreadyEmotionBonus) {
                Temperature temp = Temperature.builder()
                        .userId(null)
                        .familyId(familyId)
                        .temperature(0.1)
                        .reason(REASON_ALL_EMOTION_UPLOAD)
                        .build();
                temperatureRepository.save(temp);
            }

            // 만보기 걸음 수 충족 시 보너스
            boolean alreadyStepBonus = temperatureRepository.existsByUserIdAndFamilyIdAndReasonAndDate(null, familyId, REASON_STEP_GOAL, targetDate);
            // TODO: 가족 만보기 총 걸음수가 하루 {(부모 수) x 7,000 + (자녀 수) x 10,000}보 이상인지 검사 필요
            boolean stepGoalMet = false; // 실제 조건으로 대체 필요
            if (stepGoalMet && !alreadyStepBonus) {
                Temperature temp = Temperature.builder()
                        .userId(null)
                        .familyId(familyId)
                        .temperature(0.2)
                        .reason(REASON_STEP_GOAL)
                        .build();
                temperatureRepository.save(temp);
            }
        }
    }


    // 매주 일요일 23:59:59 에 만보기 경쟁 결과 보너스 온도 상승 처리 (후순위! 일단 안만들어도 됨)
    // TODO: 만보기 전체 경쟁 상위 10% -> +3도
    // TODO: 만보기 전체 경쟁 상위 20% -> +1도



    // 매일 23:59:59에 당일의 가족별 온도 하락 처리
    @Scheduled(cron = "59 59 23 * * *")
    @Transactional
    public void processFamilyTemperatureDecrease() {
        var families = familyRepository.findAll();
        for (var family : families) {
            String familyId = family.getCode();
            decreaseTemperatureForInactiveParent(familyId);
            decreaseTemperatureForInactiveChild(familyId);
            decreaseTemperatureForNoLogin(familyId);
        }
    }

    // 부모 1명 이상 일주일 동안안 아무 활동 없을 시 온도 하락
    public void decreaseTemperatureForInactiveParent(String familyId) {
        // 부모 1명 이상 일주일 동안 아무 활동 없을 시 온도 하락
        List<UUID> memberIds = familyRepository.findById(familyId).get().getMembers();
        List<User> users = userRepository.findAllById(memberIds);
        List<User> parents = users.stream()
                .filter(User::getIsParent)
                .toList();
        LocalDateTime since = LocalDateTime.now().minusDays(6);
        boolean parentInactive = parents.stream()
                .anyMatch(parent -> !temperatureRepository.existsByUserIdAndFamilyIdAndCreatedAtAfter(parent.getUuid(), familyId, since));
        if (parentInactive) {
            Temperature temp = Temperature.builder()
                    .userId(null)
                    .familyId(familyId)
                    .temperature(-10.0)
                    .reason("INACTIVE_PARENT")
                    .build();
            temperatureRepository.save(temp);
        }
    }

    // 자녀 1명 이상 일주일 동안안 아무 활동 없을 시 온도 하락
    public void decreaseTemperatureForInactiveChild(String familyId) {
        // 자녀 1명 이상 일주일 동안 아무 활동 없을 시 온도 하락
        List<UUID> memberIds = familyRepository.findById(familyId).get().getMembers();
        List<User> users = userRepository.findAllById(memberIds);
        List<User> children = users.stream()
                .filter(u -> !u.getIsParent())
                .toList();
        LocalDateTime since = LocalDateTime.now().minusDays(6);
        boolean childInactive = children.stream()
                .anyMatch(child -> !temperatureRepository.existsByUserIdAndFamilyIdAndCreatedAtAfter(child.getUuid(), familyId, since));
        if (childInactive) {
            Temperature temp = Temperature.builder()
                    .userId(null)
                    .familyId(familyId)
                    .temperature(-10.0)
                    .reason("INACTIVE_CHILD")
                    .build();
            temperatureRepository.save(temp);
        }
    }

    // 하루 동안 아무도 활동 없을 시 시 온도 하락
    public void decreaseTemperatureForNoLogin(String familyId) {
        // 하루 동안 아무도 활동 없을 시 온도 하락
        LocalDateTime since = LocalDate.now().atStartOfDay(); // 오늘 00:00~
        boolean noLogin = !temperatureRepository.existsByFamilyIdAndCreatedAtAfter(familyId, since);
        if (noLogin) {
            Temperature temp = Temperature.builder()
                    .userId(null)
                    .familyId(familyId)
                    .temperature(-0.5)
                    .reason("NO_LOGIN")
                    .build();
            temperatureRepository.save(temp);
        }
    }
}