package ongi.health.dto;

import java.time.LocalDate;
import ongi.health.entity.ExerciseRecord;

public record ExerciseRecordWithDiffResponse(
    Long id,
    LocalDate date,
    int duration,
    int prevDuration,
    int diff
) {
    public ExerciseRecordWithDiffResponse(ExerciseRecord entity, int prevDuration, int diff) {
        this(
            entity != null ? entity.getId() : null,
            entity != null ? entity.getDate() : null,
            entity != null ? entity.getDuration() : 0,
            prevDuration,
            diff
        );
    }
} 