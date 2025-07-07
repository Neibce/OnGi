package ongi.temperature.controller;

import lombok.RequiredArgsConstructor;
import ongi.temperature.dto.FamilyTemperatureResponse;
import ongi.temperature.dto.MemberTemperatureResponse;
import ongi.temperature.service.TemperatureService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/temperatures")
@RequiredArgsConstructor
public class TemperatureController {
    private final TemperatureService temperatureService;

    // 가족 온도 조회
    @GetMapping("/family/{familyId}")
    public ResponseEntity<FamilyTemperatureResponse> getFamilyTemperature(@PathVariable String familyId) {
        FamilyTemperatureResponse response = temperatureService.getFamilyTemperature(familyId);
        return ResponseEntity.ok(response);
    }

    // 개인별 온도 조회
    @GetMapping("/family/{familyId}/member/{userId}")
    public ResponseEntity<MemberTemperatureResponse> getMemberTemperature(
            @PathVariable String familyId,
            @PathVariable UUID userId
    ) {
        MemberTemperatureResponse response = temperatureService.getMemberTemperature(familyId, userId);
        return ResponseEntity.ok(response);
    }
} 