package ongi.pill.dto;

import ongi.pill.entity.IntakeDetail;
import ongi.pill.entity.Pill;

import java.time.DayOfWeek;
import java.time.LocalTime;
import java.util.List;
import java.util.Set;
import java.util.UUID;

public record PillInfo(
        Long id,
        String name,
        Integer times,
        IntakeDetail intakeDetail,
        List<LocalTime> intakeTimes,
        Set<DayOfWeek> intakeDays,
        UUID owner
) {
    public PillInfo(Pill pill) {
        this(pill.getId(), pill.getName(), pill.getTimes(), pill.getIntakeDetail(),
             pill.getIntakeTimes(), pill.getIntakeDays(), pill.getOwner().getUuid());
    }
} 