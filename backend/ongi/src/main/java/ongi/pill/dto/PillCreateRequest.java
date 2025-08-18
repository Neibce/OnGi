package ongi.pill.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import ongi.pill.entity.IntakeDetail;

import java.time.DayOfWeek;
import java.time.LocalTime;
import java.util.List;
import java.util.Set;
import java.util.UUID;

public record PillCreateRequest(
        @NotBlank String name,
        @NotNull Integer times,
        @NotNull IntakeDetail intakeDetail,
        @NotNull List<LocalTime> intakeTimes,
        @NotNull Set<DayOfWeek> intakeDays,
        @NotNull UUID parentUuid,
        String fileName
) {
} 