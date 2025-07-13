package ongi.family.dto;

import ongi.user.entity.User;

import java.util.UUID;

public record FamilyParentResponse(
        UUID uuid,
        String name,
        String email
) {
    public FamilyParentResponse(User user) {
        this(user.getUuid(), user.getName(), user.getEmail());
    }
} 