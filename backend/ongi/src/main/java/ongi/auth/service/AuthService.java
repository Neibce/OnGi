package ongi.auth.service;

import lombok.RequiredArgsConstructor;
import ongi.auth.dto.LoginRequest;
import ongi.auth.dto.LoginResponse;
import ongi.auth.dto.RegisterRequest;
import ongi.auth.token.util.TokenProvider;
import ongi.security.CustomUserDetails;
import ongi.user.dto.UserInfo;
import ongi.user.entity.User;
import ongi.user.repository.UserRepository;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenProvider tokenProvider;

    @Transactional
    public UserInfo register(RegisterRequest request) {
        User newUser = User.builder()
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .name(request.name())
                .isParent(request.isParent())
                .profileImageId(request.profileImageId())
                .build();

        return new UserInfo(userRepository.save(newUser));
    }

    @Transactional
    public LoginResponse login(LoginRequest request) {
        CustomUserDetails userDetails = (CustomUserDetails) authenticationManager.authenticate(
                        new UsernamePasswordAuthenticationToken(request.email(), request.password()))
                .getPrincipal();

        User user = userDetails.getUser();
        String accessToken = tokenProvider.generateAccessToken(user);
        return new LoginResponse(accessToken, new UserInfo(user));
    }
}
