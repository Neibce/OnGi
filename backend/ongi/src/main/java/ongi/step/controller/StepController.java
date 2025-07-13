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

    @PostMapping
    public ResponseEntity<Void> upsertStep(
            @Valid @RequestBody StepUpsertRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        UUID userId = userDetails.getUser().getUuid();
        stepService.upsertStep(userId, request);
        return ResponseEntity.ok().build();
    }

    @GetMapping
    public ResponseEntity<FamilyStepResponse> getFamilySteps(
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        UUID userId = userDetails.getUser().getUuid();
        FamilyStepResponse response = stepService.getFamilySteps(userId);
        return ResponseEntity.ok(response);
    }
} 
