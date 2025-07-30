package ongi.health.dto;

import java.time.LocalDate;

public record ExerciseRecordRequest(
    LocalDate date,
    int duration
) {} 