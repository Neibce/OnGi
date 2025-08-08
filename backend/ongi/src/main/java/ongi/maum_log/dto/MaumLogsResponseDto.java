package ongi.maum_log.dto;

import java.util.List;

public record MaumLogsResponseDto(
        Boolean hasUploadedOwn,
        List<MaumLogDto> maumLogDtos
) {
    public static MaumLogsResponseDto of(Boolean hasUploadedOwn, List<MaumLogDto> maumLogDtos) {
        return new MaumLogsResponseDto(hasUploadedOwn, maumLogDtos);
    }
}
