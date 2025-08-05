package ongi.health.dto;

import java.time.LocalDate;
import ongi.health.entity.ExerciseRecord;

public record ExerciseRecordSummaryResponse(
    Long id,
    LocalDate date,
    String duration // "01:50" 등
) {
    public ExerciseRecordSummaryResponse(ExerciseRecord entity) {
        this(
            entity != null ? entity.getId() : null,
            entity != null ? entity.getDate() : null,
            entity != null ? entity.getDuration() : "00:00"
        );
    }
} 