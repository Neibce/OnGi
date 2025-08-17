package ongi.user.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ongi.security.CustomUserDetails;
import ongi.user.dto.FcmTokenUpdateRequestDto;
import ongi.user.dto.UserExistsResponse;
import ongi.user.dto.UserInfo;
import ongi.user.service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequestMapping("/users")
@RestController
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<UserInfo> getCurrentUser(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        UserInfo userInfo = new UserInfo(userDetails.getUser());
        return ResponseEntity.ok(userInfo);
    }

    @GetMapping("/exists")
    public ResponseEntity<UserExistsResponse> getUserExists(String email) {
        boolean userExists = userService.getUserExists(email);
        return ResponseEntity.ok(new UserExistsResponse(userExists));
    }

    @PostMapping("fcm-token")
    public ResponseEntity<Void> updateUserFcmToken(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody FcmTokenUpdateRequestDto request) {
        userService.updateFcmToken(userDetails.getUser(), request);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }
}
