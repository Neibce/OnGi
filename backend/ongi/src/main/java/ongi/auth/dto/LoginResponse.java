package ongi.auth.dto;

import ongi.user.dto.UserInfo;

public record LoginResponse(
        String accessToken,
        UserInfo userInfo
) {

}
