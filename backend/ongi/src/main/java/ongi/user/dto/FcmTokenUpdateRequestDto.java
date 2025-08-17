package ongi.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record FcmTokenUpdateRequestDto(
        @NotNull @NotBlank String fcmToken
) {

}
