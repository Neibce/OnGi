package ongi.maum_log.dto;

import java.net.URL;
import java.util.List;
import java.util.UUID;
import ongi.maum_log.entity.MaumLog;
import ongi.maum_log.enums.Emotion;

public record MaumLogDto(
        URL frontPresignedUrl,
        URL backPresignedUrl,
        String comment,
        String location,
        List<Emotion> emotions,
        UUID uploader
) {
    public static MaumLogDto of(URL frontPresignedUrl, URL backPresignedUrl, MaumLog maumLog) {
        return new MaumLogDto(
                frontPresignedUrl,
                backPresignedUrl,
                maumLog.getComment(),
                maumLog.getLocation(),
                maumLog.getEmotions(),
                maumLog.getCreatedBy().getUuid()
        );
    }
}
