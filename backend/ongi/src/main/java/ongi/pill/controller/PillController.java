package ongi.pill.controller;

import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import ongi.pill.dto.PillCreateRequest;
import ongi.pill.dto.PillInfo;
import ongi.pill.dto.PillInfoWithIntakeStatus;
import ongi.pill.dto.PillIntakeRecordRequest;
import ongi.pill.service.PillService;
import ongi.security.CustomUserDetails;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.Nullable;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/pills")
@RequiredArgsConstructor
public class PillController {

    private final PillService pillService;

    @PostMapping
    public ResponseEntity<PillInfo> createPill(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody PillCreateRequest request) {
        PillInfo pillInfo = pillService.createPill(userDetails.getUser(), request);
        return ResponseEntity.ok(pillInfo);
    }

    @PostMapping("/record")
    public ResponseEntity<Void> recordPillIntake(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody PillIntakeRecordRequest request) {
        pillService.recordPillIntake(userDetails.getUser(), request);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @GetMapping
    public ResponseEntity<List<PillInfoWithIntakeStatus>> getPills(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam @Nullable UUID parentUuid,
            @RequestParam @Nullable LocalDate date) {
        if (date == null) {
            date = LocalDate.now();
        }
        List<PillInfoWithIntakeStatus> pills = pillService.getFamilyPills(userDetails.getUser(), parentUuid, date);
        return ResponseEntity.ok(pills);
    }
}
