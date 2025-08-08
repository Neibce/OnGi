package ongi.maum_log.dto;

import jakarta.validation.constraints.NotNull;
import java.util.List;
import ongi.maum_log.enums.Emotion;

public record MaumLogUploadRequestDto(
        @NotNull String frontFileName,
        @NotNull String backFileName,
        String location,
        String comment,
        List<Emotion> emotions
) {

}
