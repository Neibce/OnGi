package ongi.pill.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ongi.pill.dto.PillCreateRequest;
import ongi.pill.dto.PillInfo;
import ongi.pill.service.PillService;
import ongi.security.CustomUserDetails;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
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

    @GetMapping
    public ResponseEntity<List<PillInfo>> getMyPills(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        List<PillInfo> pills = pillService.getMyPills(userDetails.getUser());
        return ResponseEntity.ok(pills);
    }

    @GetMapping("/family")
    public ResponseEntity<List<PillInfo>> getFamilyPills(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        List<PillInfo> pills = pillService.getFamilyPills(userDetails.getUser());
        return ResponseEntity.ok(pills);
    }
}
