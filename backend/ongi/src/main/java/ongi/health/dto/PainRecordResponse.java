package ongi.health.dto;

import java.time.LocalDate;
import java.util.List;
import ongi.health.entity.PainRecord;

public record PainRecordResponse(
    Long id,
    LocalDate date,
    List<String> painArea
) {
    public PainRecordResponse(PainRecord entity) {
        this(
            entity.getId(),
            entity.getDate(),
            entity.getPainArea().stream()
                    .map(PainRecord.PainArea::name)
                    .toList()
        );
    }
} 