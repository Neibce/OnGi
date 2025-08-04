package ongi.maum_log.dto;

import jakarta.validation.constraints.NotNull;
import java.util.List;
import ongi.maum_log.enums.Emotion;

public record MaumLogUploadRequestDto(
        @NotNull
        String fileName,

        @NotNull
        String fileExtension,

        String location,

        String comment,

        List<Emotion> emotions
) {

}
