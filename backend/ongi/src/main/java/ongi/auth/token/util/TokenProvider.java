package ongi.auth.token.util;

import jakarta.servlet.http.HttpServletRequest;
import java.util.UUID;
import lombok.AllArgsConstructor;
import ongi.auth.token.entity.AccessToken;
import ongi.auth.token.repository.AccessTokenRepository;
import ongi.security.CustomUserDetails;
import ongi.user.entity.User;
import ongi.user.repository.UserRepository;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@AllArgsConstructor
@Transactional(readOnly = true)
public class TokenProvider {

    private final AccessTokenRepository accessTokenRepository;
    private final UserRepository userRepository;

    @Transactional
    public String generateAccessToken(User user) {
        String token = UUID.randomUUID().toString().replace("-", "");
        accessTokenRepository.save(
                new AccessToken(null, token, user.getUuid(), null));
        return token;
    }

    public boolean validateToken(String token) {
        return accessTokenRepository.existsByToken(token);
    }

    public String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }

    public Authentication getAuthentication(String token) {
        AccessToken accessToken = accessTokenRepository.getByToken(token)
                .orElseThrow(() -> new BadCredentialsException("유효하지 않은 토큰입니다."));

        UserDetails userDetails = new CustomUserDetails(
                userRepository.findByUuid(accessToken.getUserId())
                        .orElseThrow(() -> new UsernameNotFoundException("사용자를 찾을 수 없습니다.")));

        return new UsernamePasswordAuthenticationToken(
                userDetails, null, userDetails.getAuthorities());
    }
}
