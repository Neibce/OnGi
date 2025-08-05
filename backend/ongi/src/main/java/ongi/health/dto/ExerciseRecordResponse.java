package ongi.health.dto;

import java.time.LocalDate;
import ongi.health.entity.ExerciseRecord;

public record ExerciseRecordResponse(
    Long id,
    LocalDate date,
    int[][] grid, // 2차원 배열
    String duration // "01:50" 등
) {
    public ExerciseRecordResponse(ExerciseRecord entity) {
        this(
            entity != null ? entity.getId() : null,
            entity != null ? entity.getDate() : null,
            entity != null ? entity.getGrid() : null,
            entity != null ? entity.getDuration() : "00:00"
        );
    }
}
 