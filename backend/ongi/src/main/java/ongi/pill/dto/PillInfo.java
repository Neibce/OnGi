package ongi.pill.dto;

import ongi.pill.entity.IntakeDetail;
import ongi.pill.entity.Pill;

import java.time.LocalDateTime;
import java.util.UUID;

public record PillInfo(
        Long id,
        String name,
        IntakeDetail intakeDetail,
        LocalDateTime intakeTime,
        UUID owner
) {
    public PillInfo(Pill pill) {
        this(pill.getId(), pill.getName(), pill.getIntakeDetail(), pill.getIntakeTime(), pill.getOwner());
    }
} 