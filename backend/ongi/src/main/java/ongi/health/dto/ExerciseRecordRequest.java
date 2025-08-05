package ongi.health.dto;

import java.time.LocalDate;

public record ExerciseRecordRequest(
    LocalDate date,
    String grid // 길이 144, "010001..."
) {} 