package ongi.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record RegisterRequest(

        @NotBlank(message = "이메일은 필수 입력값입니다.")
        @Email(message = "이메일 형식이 아닙니다.")
        String email,

        @NotBlank(message = "비밀번호는 필수 입력값입니다.")
        String password,

        @NotBlank(message = "이름은 필수 입력값입니다.")
        String name,

        @NotNull(message = "부모 여부는 필수 입력값입니다.")
        Boolean isParent,

        @NotNull(message = "프로필 이미지 ID는 필수 입력값입니다.")
        Integer profileImageId

) {

}
