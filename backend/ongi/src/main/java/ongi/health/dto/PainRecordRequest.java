package ongi.health.dto;

import java.time.LocalDate;
import java.util.List;

public record PainRecordRequest(
    LocalDate date,
    List<String> painArea
) {} 