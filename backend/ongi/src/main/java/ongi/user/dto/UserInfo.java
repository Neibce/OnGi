package ongi.user.dto;

import java.time.LocalDateTime;
import java.util.UUID;
import ongi.user.entity.User;

public record UserInfo(
        UUID uuid,
        String email,
        String name,
        Boolean isParent,
        Integer profileImageId,
        LocalDateTime createdAt,
        LocalDateTime updatedAt

) {
    public UserInfo(User user){
        this(
                user.getUuid(),
                user.getEmail(),
                user.getName(),
                user.getIsParent(),
                user.getProfileImageId(),
                user.getCreatedAt(),
                user.getUpdatedAt()
        );
    }
}
