package ongi.user.controller;

import lombok.RequiredArgsConstructor;
import ongi.security.CustomUserDetails;
import ongi.user.dto.UserInfo;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequestMapping("/users")
@RestController
@RequiredArgsConstructor
public class UserController {

    @GetMapping("/me")
    public ResponseEntity<UserInfo> getCurrentUser(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        UserInfo userInfo = new UserInfo(userDetails.getUser());
        return ResponseEntity.ok(userInfo);
    }
}
