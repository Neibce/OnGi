package ongi.step.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record StepUpsertRequest(
        @NotNull(message = "걸음 수는 필수입니다.")
        @Min(value = 0, message = "걸음 수는 0 이상이어야 합니다.")
        Integer steps
) {
} 
