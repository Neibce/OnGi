package ongi.step.dto;

public record FamilyStepRankResponse(
        String familyName,
        Integer averageSteps,
        Boolean isOurFamily
) {

}
