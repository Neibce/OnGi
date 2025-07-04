package ongi.family.dto;

import java.time.LocalDateTime;
import ongi.family.entity.Family;

public record FamilyInfo(
        String code,
        String name,
        Integer memberCount,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {

    public FamilyInfo(Family family) {
        this(family.getCode(), family.getName(), family.getMembers().size(), family.getCreatedAt(),
                family.getUpdatedAt());
    }
}
