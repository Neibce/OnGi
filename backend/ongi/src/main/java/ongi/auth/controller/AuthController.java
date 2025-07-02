package ongi.auth.controller;

import jakarta.validation.Valid;
import java.net.URI;
import lombok.RequiredArgsConstructor;
import ongi.auth.dto.LoginRequest;
import ongi.auth.dto.LoginResponse;
import ongi.auth.dto.RegisterRequest;
import ongi.auth.service.AuthService;
import ongi.user.dto.UserInfo;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequestMapping("/auth")
@RestController
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<UserInfo> register(@Valid @RequestBody RegisterRequest request) {
        UserInfo createdUser = authService.register(request);
        URI location = URI.create("/users/" + createdUser.uuid());
        return ResponseEntity.created(location).body(createdUser);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse loginResponse = authService.login(request);
        return ResponseEntity.ok(loginResponse);
    }
}
