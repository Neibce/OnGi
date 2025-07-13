package ongi.pill.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import ongi.pill.entity.IntakeDetail;

import java.time.LocalDateTime;
import java.util.UUID;

public record PillCreateRequest(
        @NotBlank String name,
        @NotNull IntakeDetail intakeDetail,
        @NotNull LocalDateTime intakeTime,
        @NotNull UUID parentUuid
) {
} 