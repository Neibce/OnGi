package ongi.health.dto;

import java.time.LocalDate;

public record PainRecordRequest(
    LocalDate date,
    String painArea,
    String painLevel
) {} 