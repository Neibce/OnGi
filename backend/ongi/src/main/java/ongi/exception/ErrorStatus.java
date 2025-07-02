package ongi.exception;


import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ErrorStatus {
    INTERNAL_SERVER_ERROR(-1, "Internal Server Error"),
    ENTITY_NOT_FOUND(2, "Entity Not Found"),
    BAD_CREDENTIALS(3, "아이디 혹은 비밀번호가 일치하지 않습니다."),
    VALIDATION_ERROR(-2, "Validation error"),
    REQUEST_BODY_ERROR(-3, "Request body error"),
    METHOD_NOT_ALLOWED(-4, "Method Not Allowed");

    private final int code;
    private final String defaultMessage;
}

