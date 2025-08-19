package ongi.pill.dto;

import java.net.URL;

public record PillPresignedResponseDto(
        URL presignedUrl,
        String fileName
) {

}
