package ongi.step.controller;

import lombok.RequiredArgsConstructor;
import ongi.security.CustomUserDetails;
import ongi.step.dto.FamilyStepResponse;
import ongi.step.dto.StepUpsertRequest;
import ongi.step.service.StepService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.UUID;

@RestController
@RequestMapping("/steps")
@RequiredArgsConstructor
public class StepController {
    
    private final StepService stepService;

    /**
     * Creates or updates step data for the authenticated user.
     *
     * Accepts a validated step upsert request and associates the data with the user's UUID.
     *
     * @return HTTP 200 OK with no response body upon successful completion.
     */
    @PostMapping
    public ResponseEntity<Void> upsertStep(
            @Valid @RequestBody StepUpsertRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        UUID userId = userDetails.getUser().getUuid();
        stepService.upsertStep(userId, request);
        return ResponseEntity.ok().build();
    }

    /**
     * Retrieves step data for the authenticated user's family.
     *
     * @param userDetails the authenticated user's details
     * @return a response entity containing the family step data
     */
    @GetMapping
    public ResponseEntity<FamilyStepResponse> getFamilySteps(
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        UUID userId = userDetails.getUser().getUuid();
        FamilyStepResponse response = stepService.getFamilySteps(userId);
        return ResponseEntity.ok(response);
    }
} 