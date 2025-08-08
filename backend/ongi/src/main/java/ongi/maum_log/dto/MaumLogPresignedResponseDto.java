package ongi.maum_log.dto;

public record MaumLogPresignedResponseDto(
        String frontFileName,
        String frontPresignedUrl,
        String backFileName,
        String backPresignedUrl
) {
    public static MaumLogPresignedResponseDto from(
            String frontFileName,
            String frontPresignedUrl,
            String backFileName,
            String backPresignedUrl
    ) {
        return new MaumLogPresignedResponseDto(
                frontFileName,
                frontPresignedUrl,
                backFileName,
                backPresignedUrl
        );
    }
}
