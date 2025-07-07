package ongi.temperature.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MemberTemperatureResponse {
    private UUID userId;
    private String userName;
    private Double contributedTemperature;
    private Double percentage;
    private List<TemperatureRecord> temperatureRecords;
    
    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TemperatureRecord {
        private Long temperatureId;
        private Double temperature;
        private String activity;
        private LocalDateTime createdAt;
    }
} 