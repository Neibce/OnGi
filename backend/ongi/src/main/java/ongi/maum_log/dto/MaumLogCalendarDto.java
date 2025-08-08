package ongi.maum_log.dto;

import java.time.LocalDate;
import java.util.Map;

public record MaumLogCalendarDto(
        Integer totalMemberCount,
        Map<LocalDate, Integer> writtenMemberCount
) {
    public static MaumLogCalendarDto from(Integer totalMemberCount, Map<LocalDate, Integer> writtenMemberCount) {
        return new MaumLogCalendarDto(totalMemberCount, writtenMemberCount);
    }
}
