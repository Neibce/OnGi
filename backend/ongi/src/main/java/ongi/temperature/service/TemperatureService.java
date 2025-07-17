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

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TemperatureService {
    private final TemperatureRepository temperatureRepository;
    private final FamilyRepository familyRepository;
    private final UserRepository userRepository;
    private static final double BASE_TEMPERATURE = 36.5;

    // 가족 온도 그래프 및 기여도 조회
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
                            .contributedTemperature(contributedTemperature)
                            .percentage(percentage)
                            .build();
                })
                .collect(Collectors.toList());

        return FamilyTemperatureResponse.builder()
                .familyTemperature(familyTemperature)
                .totalContributedTemperature(contributedSum)
                .memberTemperatures(memberTemperatures)
                .build();
    }

    // 최근 5일간 가족 온도 총합 조회
    public FamilyTemperatureDailyResponse getFamilyTemperatureDaily(String familyId) {
        familyRepository.findById(familyId)
                .orElseThrow(() -> new EntityNotFoundException("가족을 찾을 수 없습니다."));
        java.time.LocalDateTime fromDate = java.time.LocalDate.now().minusDays(4).atStartOfDay(); // 최근 5일
        List<Object[]> rawList = temperatureRepository.getFamilyTemperatureDailyRaw(familyId, fromDate);
        List<FamilyTemperatureDailyResponse.DailyTemperature> dailyList = rawList.stream()
            .map(arr -> new FamilyTemperatureDailyResponse.DailyTemperature(
                (java.time.LocalDate) arr[0],
                (Double) arr[1]
            ))
            .toList();
        return new FamilyTemperatureDailyResponse(dailyList);
    }

    // 최근 5일간 가족 구성원별 온도 기여 내역 조회
    public FamilyTemperatureContributionResponse getFamilyTemperatureContributions(String familyId) {
        familyRepository.findById(familyId)
                .orElseThrow(() -> new EntityNotFoundException("가족을 찾을 수 없습니다."));
        java.time.LocalDateTime fromDate = java.time.LocalDate.now().minusDays(4).atStartOfDay(); // 최근 5일
        List<Object[]> rawList = temperatureRepository.getFamilyTemperatureContributionsRaw(familyId, fromDate);
        List<FamilyTemperatureContributionResponse.Contribution> contributions = rawList.stream()
            .map(arr -> new FamilyTemperatureContributionResponse.Contribution(
                (java.time.LocalDate) arr[0],
                (java.util.UUID) arr[1],
                (Double) arr[2]
            ))
            .toList();
        return new FamilyTemperatureContributionResponse(contributions);
    }




    // 온도 상승 메서드
    // 감정기록 업로드 시 온도 상승 (하루 1회만 적용)
    public void increaseTemperatureForEmotionUpload(UUID userId, String familyId) {
        // TODO: 하루 1회 제한 및 온도 상승(+0.1도) 로직 구현
    }

    // 가족 모두 감정기록 업로드 시 온도 추가 상승
    public void increaseTemperatureForAllEmotionUpload(String familyId) {
        // TODO: 가족 모두 업로드 확인 및 온도 추가 상승(+0.5도) 로직 구현
    }

    // 부모 건강 정보 입력 시 온도 상승 (최대 0.6도)
    public void increaseTemperatureForParentHealthInput(UUID userId, String familyId) {
        // TODO: 하루 최대 0.6도까지 온도 상승(+0.2도씩) 로직 구현
    }

    // 자녀가 부모 건강 정보 열람 시 온도 상승 (최대 0.9도)
    public void increaseTemperatureForChildHealthView(UUID userId, String familyId) {
        // TODO: 하루 최대 0.9도까지 온도 상승(+0.3도씩) 로직 구현
    }

    // 가족 만보기 걸음수 충족 시 온도 상승
    public void increaseTemperatureForStepGoal(String familyId) {
        // TODO: 걸음수 충족 시 온도 상승(+0.2도) 로직 구현
    }


    // 온도 하락 메서드
    // 부모 1명 이상 일주일 미접속 시 온도 하락
    public void decreaseTemperatureForInactiveParent(String familyId) {
        // TODO: 부모 미접속 시 온도 하락(-15도) 로직 구현
    }

    // 자녀 1명 이상 일주일 미접속 시 온도 하락
    public void decreaseTemperatureForInactiveChild(String familyId) {
        // TODO: 자녀 미접속 시 온도 하락(-15도) 로직 구현
    }

    // 하루 동안 아무도 미접속 시 온도 하락
    public void decreaseTemperatureForNoLogin(String familyId) {
        // TODO: 하루 미접속 시 온도 하락(-1도) 로직 구현
    }
}