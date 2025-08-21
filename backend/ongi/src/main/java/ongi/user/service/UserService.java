package ongi.user.service;

import lombok.RequiredArgsConstructor;
import ongi.user.dto.FcmTokenUpdateRequestDto;
import ongi.user.entity.User;
import ongi.user.entity.UserFcmToken;
import ongi.user.repository.UserFcmTokenRepository;
import ongi.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;
    private final UserFcmTokenRepository userFcmTokenRepository;

    public boolean getUserExists(String email) {
        return userRepository.existsByEmail(email);
    }

    @Transactional
    public void updateFcmToken(User user, FcmTokenUpdateRequestDto requestDto) {
        UserFcmToken userFcmToken = userFcmTokenRepository.findByUser(user).orElse(
                UserFcmToken.builder().user(user).build());
        userFcmToken.setToken(requestDto.fcmToken());

        userFcmTokenRepository.save(userFcmToken);
    }
}
