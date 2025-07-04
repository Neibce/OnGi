package ongi.user.service;

import lombok.RequiredArgsConstructor;
import ongi.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;

    public boolean getUserExists(String email) {
        return userRepository.existsByEmail(email);
    }
}
