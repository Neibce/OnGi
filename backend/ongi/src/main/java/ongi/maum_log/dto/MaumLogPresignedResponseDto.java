package ongi.maum_log.dto;

public record MaumLogPresignedResponseDto(
        String presignedUrl,
        String fileName
) {
    public static MaumLogPresignedResponseDto from(String presignedUrl, String fileName) {
        return new MaumLogPresignedResponseDto(presignedUrl, fileName);
    }
}
