package ongi.step.controller;

import jakarta.annotation.Nullable;
import java.time.LocalDate;
import lombok.RequiredArgsConstructor;
import ongi.security.CustomUserDetails;
import ongi.step.dto.FamilyStepResponse;
import ongi.step.dto.StepUpsertRequest;
import ongi.step.service.StepService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/steps")
@RequiredArgsConstructor
public class StepController {

    private final StepService stepService;

    @PostMapping
    public ResponseEntity<Void> upsertStep(
            @Valid @RequestBody StepUpsertRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        stepService.upsertStep(userDetails.getUser(), request);
        return ResponseEntity.ok().build();
    }

    @GetMapping
    public ResponseEntity<FamilyStepResponse> getFamilySteps(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam @Nullable LocalDate date) {
        if (date == null) {
            date = LocalDate.now();
        }
        FamilyStepResponse response = stepService.getFamilySteps(userDetails.getUser(), date);
        return ResponseEntity.ok(response);
    }
} 
