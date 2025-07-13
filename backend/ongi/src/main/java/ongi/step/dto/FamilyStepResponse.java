package ongi.step.dto;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record FamilyStepResponse(
        Integer totalSteps,
        LocalDate date,
        List<MemberStepInfo> memberSteps
) {
    
    public record MemberStepInfo(
            UUID userId,
            String userName,
            Integer steps
    ) {
    }
} 