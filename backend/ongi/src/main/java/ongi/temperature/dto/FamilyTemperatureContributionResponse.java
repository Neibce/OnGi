package ongi.temperature.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Getter
@AllArgsConstructor
public class FamilyTemperatureContributionResponse {
    private List<Contribution> contributions;

    @Getter
    @AllArgsConstructor
    public static class Contribution {
        private LocalDate date;
        private UUID userId;
        private Double contributed;
    }
} 