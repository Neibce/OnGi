package ongi.auth.token.repository;

import java.util.Optional;
import ongi.auth.token.entity.AccessToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AccessTokenRepository extends JpaRepository<AccessToken, Long> {

    boolean existsByToken(String token);

    Optional<AccessToken> getByToken(String token);
}
