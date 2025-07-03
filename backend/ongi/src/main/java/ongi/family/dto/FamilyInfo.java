package ongi.family.dto;

import java.time.LocalDateTime;
import ongi.family.entity.Family;

public record FamilyInfo(
        String code,
        Integer memberCount,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
    public FamilyInfo(Family family){
        this(family.getCode(), family.getMembers().size(), family.getCreatedAt(), family.getUpdatedAt());
    }
}
