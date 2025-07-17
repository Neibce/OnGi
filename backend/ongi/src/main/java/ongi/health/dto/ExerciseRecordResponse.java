package ongi.health.dto;

import java.time.LocalDate;
import ongi.health.entity.ExerciseRecord;

public record ExerciseRecordResponse(
    Long id,
    LocalDate date,
    int duration
) {
    public ExerciseRecordResponse(ExerciseRecord entity) {
        this(
            entity != null ? entity.getId() : null,
            entity != null ? entity.getDate() : null,
            entity != null ? entity.getDuration() : 0
        );
    }
} 