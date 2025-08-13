package ongi.user.service;

import java.util.Optional;
import ongi.user.entity.User;
import ongi.user.entity.UserFcmToken;
import org.springframework.data.jpa.repository.JpaRepository;

interface UserFcmTokenRepository extends JpaRepository<UserFcmToken, Long> {

    Optional<UserFcmToken> findByUser(User user);
}
