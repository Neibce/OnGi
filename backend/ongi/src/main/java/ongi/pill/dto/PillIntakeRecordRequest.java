package ongi.pill.dto;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.LocalTime;

public record PillIntakeRecordRequest(
        @NotNull Long pillId,
        @NotNull LocalTime intakeTime,
        @NotNull LocalDate intakeDate
) {
}