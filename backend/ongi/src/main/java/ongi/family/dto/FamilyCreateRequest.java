package ongi.family.dto;

import jakarta.validation.constraints.NotBlank;

public record FamilyCreateRequest(
        @NotBlank(message = "가족 이름은 필수입니다.")
        String name
) {

}
