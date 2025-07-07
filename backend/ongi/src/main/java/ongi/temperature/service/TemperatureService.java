package ongi.temperature.service;

import lombok.RequiredArgsConstructor;
import ongi.exception.EntityNotFoundException;
import ongi.family.entity.Family;
import ongi.family.repository.FamilyRepository;
import ongi.temperature.dto.FamilyTemperatureResponse;
import ongi.temperature.dto.MemberTemperatureResponse;
import ongi.temperature.entity.Temperature;
import ongi.temperature.repository.TemperatureRepository;
import ongi.user.entity.User;
import ongi.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TemperatureService {
    
    private final TemperatureRepository temperatureRepository;
    private final FamilyRepository familyRepository;
    private final UserRepository userRepository;
    
    private static final double BASE_TEMPERATURE = 36.5;
    
    public FamilyTemperatureResponse getFamilyTemperature(String familyId) {
        // 가족 존재 확인
        Family family = familyRepository.findById(familyId)
                .orElseThrow(() -> new EntityNotFoundException("가족을 찾을 수 없습니다."));
        
        // 가족의 모든 온도 기록 조회
        List<Temperature> temperatures = temperatureRepository.findByFamilyId(familyId);
        
        // 전체 온도 합계 계산 (Repository 메서드 사용)
        Double totalContributedTemperature = temperatureRepository.getTotalTemperatureByFamilyId(familyId);
        final Double finalTotalContributedTemperature = totalContributedTemperature != null ? totalContributedTemperature : 0.0;
        
        // 가족 온도 계산 (기본값 + 기여 온도)
        Double familyTemperature = BASE_TEMPERATURE + finalTotalContributedTemperature;
        
        // 사용자별 온도 합계 계산 (여전히 필요 - 개별 사용자 정보를 위해)
        Map<UUID, Double> userTemperatures = temperatures.stream()
                .collect(Collectors.groupingBy(
                        Temperature::getUserId,
                        Collectors.summingDouble(Temperature::getTemperature)
                ));
        
        // 사용자 정보 조회
        List<UUID> userIds = userTemperatures.keySet().stream().toList();
        Map<UUID, User> users = userRepository.findAllById(userIds).stream()
                .collect(Collectors.toMap(User::getUuid, user -> user));
        
        // 멤버별 온도 정보 생성
        List<FamilyTemperatureResponse.MemberTemperatureInfo> memberTemperatures = userTemperatures.entrySet().stream()
                .map(entry -> {
                    UUID userId = entry.getKey();
                    Double contributedTemperature = entry.getValue();
                    User user = users.get(userId);
                    
                    // 퍼센트 계산
                    Double percentage = finalTotalContributedTemperature > 0 
                            ? (contributedTemperature / finalTotalContributedTemperature) * 100 
                            : 0.0;
                    
                    // 소수점 2자리로 반올림
                    percentage = BigDecimal.valueOf(percentage)
                            .setScale(2, RoundingMode.HALF_UP)
                            .doubleValue();
                    
                    return FamilyTemperatureResponse.MemberTemperatureInfo.builder()
                            .userId(userId)
                            .userName(user.getName())
                            .contributedTemperature(contributedTemperature)
                            .percentage(percentage)
                            .build();
                })
                .collect(Collectors.toList());
        
        return FamilyTemperatureResponse.builder()
                .familyTemperature(familyTemperature)
                .totalContributedTemperature(finalTotalContributedTemperature)
                .memberTemperatures(memberTemperatures)
                .build();
    }
    
    public MemberTemperatureResponse getMemberTemperature(String familyId, UUID userId) {
        // 가족 존재 확인
        Family family = familyRepository.findById(familyId)
                .orElseThrow(() -> new EntityNotFoundException("가족을 찾을 수 없습니다."));
        
        // 사용자 존재 확인
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("사용자를 찾을 수 없습니다."));
        
        // 사용자가 기여한 온도 합계 (Repository 메서드 사용)
        Double contributedTemperature = temperatureRepository.getTotalTemperatureByFamilyIdAndUserId(familyId, userId);
        if (contributedTemperature == null) {
            contributedTemperature = 0.0;
        }
        
        // 사용자의 온도 기록 조회 (상세 정보를 위해)
        List<Temperature> temperatures = temperatureRepository.findByFamilyIdAndUserId(familyId, userId);
        
        // 전체 기여 온도 합계
        Double totalContributedTemperature = temperatureRepository.getTotalTemperatureByFamilyId(familyId);
        if (totalContributedTemperature == null) {
            totalContributedTemperature = 0.0;
        }
        
        // 퍼센트 계산
        Double percentage = totalContributedTemperature > 0 
                ? (contributedTemperature / totalContributedTemperature) * 100 
                : 0.0;
        
        // 소수점 2자리로 반올림
        percentage = BigDecimal.valueOf(percentage)
                .setScale(2, RoundingMode.HALF_UP)
                .doubleValue();
        
        // 온도 기록 변환
        List<MemberTemperatureResponse.TemperatureRecord> temperatureRecords = temperatures.stream()
                .map(temp -> MemberTemperatureResponse.TemperatureRecord.builder()
                        .temperatureId(temp.getId())
                        .temperature(temp.getTemperature())
                        .activity(temp.getActivity())
                        .createdAt(temp.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
        
        return MemberTemperatureResponse.builder()
                .userId(userId)
                .userName(user.getName())
                .contributedTemperature(contributedTemperature)
                .percentage(percentage)
                .temperatureRecords(temperatureRecords)
                .build();
    }
} 