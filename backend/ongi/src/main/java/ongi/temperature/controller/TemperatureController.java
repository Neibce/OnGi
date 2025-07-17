package ongi.temperature.controller;

import lombok.RequiredArgsConstructor;
import ongi.temperature.dto.FamilyTemperatureResponse;
import ongi.temperature.dto.FamilyTemperatureDailyResponse;
import ongi.temperature.dto.FamilyTemperatureContributionResponse;
import ongi.temperature.service.TemperatureService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/temperature")
@RequiredArgsConstructor
public class TemperatureController {
    private final TemperatureService temperatureService;

    // 가족 온도 그래프 및 기여도 조회
    @GetMapping("/summary")
    public ResponseEntity<FamilyTemperatureResponse> getFamilyTemperatureSummary(@RequestParam String familyId) {
        return ResponseEntity.ok(temperatureService.getFamilyTemperatureSummary(familyId));
    }

    // 최근 5일간 가족 온도 총합 조회
    @GetMapping("/daily")
    public ResponseEntity<FamilyTemperatureDailyResponse> getFamilyTemperatureDaily(@RequestParam String familyId) {
        return ResponseEntity.ok(temperatureService.getFamilyTemperatureDaily(familyId));
    }

    // 최근 5일간 가족 구성원별 온도 기여 내역 조회
    @GetMapping("/contributions")
    public ResponseEntity<FamilyTemperatureContributionResponse> getFamilyTemperatureContributions(@RequestParam String familyId) {
        return ResponseEntity.ok(temperatureService.getFamilyTemperatureContributions(familyId));
    }
}