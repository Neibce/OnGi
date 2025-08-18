package ongi.maum_log.dto;

import java.net.URL;
import java.util.List;
import ongi.maum_log.entity.MaumLog;
import ongi.maum_log.enums.Emotion;
import ongi.user.dto.UserInfo;

public record MaumLogDto(
        URL frontPresignedUrl,
        URL backPresignedUrl,
        String comment,
        String location,
        List<Emotion> emotions,
        UserInfo uploader
) {
    public static MaumLogDto of(URL frontPresignedUrl, URL backPresignedUrl, MaumLog maumLog) {
        return new MaumLogDto(
                frontPresignedUrl,
                backPresignedUrl,
                maumLog.getComment(),
                maumLog.getLocation(),
                maumLog.getEmotions(),
                new UserInfo(maumLog.getCreatedBy())
        );
    }
}
