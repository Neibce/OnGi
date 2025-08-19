package ongi.pill.dto;

import java.net.URL;
import java.time.temporal.ChronoUnit;
import ongi.pill.entity.IntakeDetail;
import ongi.pill.entity.Pill;
import ongi.pill.entity.PillIntakeRecord;

import java.time.DayOfWeek;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

public record PillInfoWithIntakeStatus(
        Long id,
        String name,
        URL imageUrl,
        Integer times,
        IntakeDetail intakeDetail,
        List<LocalTime> intakeTimes,
        Set<DayOfWeek> intakeDays,
        UUID owner,
        Map<LocalTime, LocalTime> dayIntakeStatus
) {

    public PillInfoWithIntakeStatus(Pill pill, URL imageUrl, List<PillIntakeRecord> intakeRecords) {
        this(
                pill.getId(),
                pill.getName(),
                imageUrl,
                pill.getTimes(),
                pill.getIntakeDetail(),
                pill.getIntakeTimes(),
                pill.getIntakeDays(),
                pill.getOwner().getUuid(),
                createIntakeStatusMap(intakeRecords)
        );
    }

    private static Map<LocalTime, LocalTime> createIntakeStatusMap(
            List<PillIntakeRecord> intakeRecords) {
        return intakeRecords.stream()
                .collect(Collectors.toMap(
                        PillIntakeRecord::getIntakeTime,
                        record -> record.getCreatedAt().toLocalTime()
                                .truncatedTo(ChronoUnit.SECONDS)
                ));
    }
}
