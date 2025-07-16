package ongi.temperature.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FamilyTemperatureResponse {
    private Double familyTemperature;
    private Double totalContributedTemperature;
    private List<MemberTemperatureInfo> memberTemperatures;

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MemberTemperatureInfo {
        private UUID userId;
        private String userName;
        private Double contributedTemperature;
        private Double percentage;
    }
} 