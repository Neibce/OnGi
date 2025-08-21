package ongi.user.repository;

import java.util.Optional;
import java.util.UUID;
import ongi.user.entity.User;
import ongi.user.entity.UserFcmToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserFcmTokenRepository extends JpaRepository<UserFcmToken, Long> {

    Optional<UserFcmToken> findByUser_Uuid(UUID userUuid);

    Optional<UserFcmToken> findByUser(User user);
}
