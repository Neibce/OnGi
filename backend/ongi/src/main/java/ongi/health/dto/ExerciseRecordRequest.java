package ongi.health.dto;

import java.time.LocalDate;

public record ExerciseRecordRequest(
    LocalDate date,
    int[][] grid // 2차원 배열(24행 6열)
) {} 