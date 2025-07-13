package ongi.health.dto;

import java.time.LocalDate;
import ongi.health.entity.PainRecord;

public record PainRecordResponse(
    Long id,
    LocalDate date,
    String painArea,
    String painLevel
) {
    public PainRecordResponse(PainRecord entity) {
        this(
            entity.getId(),
            entity.getDate(),
            entity.getPainArea().name(),
            entity.getPainLevel().name()
        );
    }
} 