package ongi.common.dto;

public record ErrorResponse(
        int statusCode,
        String message
) {

}

