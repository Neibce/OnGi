package ongi.temperature.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import java.time.LocalDate;
import java.util.List;

@Getter
@AllArgsConstructor
public class FamilyTemperatureDailyResponse {
    private List<DailyTemperature> dailyTemperatures;

    @Getter
    @AllArgsConstructor
    public static class DailyTemperature {
        private LocalDate date;
        private Double totalTemperature;
    }
} 