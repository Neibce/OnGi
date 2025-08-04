package ongi.maum_log.dto;

import java.util.List;
import ongi.maum_log.enums.Emotion;

public record MaumLogUploadRequestDto(
        String fileName,
        String fileExtension,
        String location,
        String comment,
        List<Emotion> emotions
) {

}
