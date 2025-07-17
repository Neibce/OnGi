package ongi.health.controller;

import lombok.RequiredArgsConstructor;
import ongi.health.entity.PainRecord;
import ongi.health.entity.ExerciseRecord;
import ongi.health.service.HealthRecordService;
import ongi.security.CustomUserDetails;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import ongi.health.dto.PainRecordResponse;
import ongi.health.dto.ExerciseRecordResponse;

@RestController
@RequestMapping("/health")
@RequiredArgsConstructor
public class HealthRecordController {
    private final HealthRecordService healthRecordService;

    // 통증 기록 추가
    @PostMapping("/pain")
    public ResponseEntity<PainRecordResponse> addPainRecord(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam PainRecord.PainArea area,
            @RequestParam PainRecord.PainLevel level
    ) {
        PainRecord record = healthRecordService.addPainRecord(userDetails.getUser().getUuid(), date, area, level);
        PainRecordResponse response = new PainRecordResponse(record);
        return ResponseEntity.ok(response);
    }

    // 운동 기록 추가
    @PostMapping("/exercise")
    public ResponseEntity<ExerciseRecordResponse> addExerciseRecord(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam int duration
    ) {
        ExerciseRecord record = healthRecordService.addExerciseRecord(userDetails.getUser().getUuid(), date, duration);
        ExerciseRecordResponse response = new ExerciseRecordResponse(record);
        return ResponseEntity.ok(response);
    }

    // 최근 7일간 통증 기록 조회
    @GetMapping("/pain/view")
    public ResponseEntity<List<PainRecordResponse>> getParentPainRecordsForLast7Days(
            @RequestParam UUID parentId
    ) {
        List<PainRecordResponse> response = healthRecordService.getPainRecordsForLast7Days(parentId).stream()
            .map(PainRecordResponse::new)
            .toList();
        return ResponseEntity.ok(response);
    }

    // 최근 7일간 운동 기록 조회
    @GetMapping("/exercise/view")
    public ResponseEntity<List<ExerciseRecordResponse>> getParentExerciseRecordsForLast7Days(
            @RequestParam UUID parentId
    ) {
        List<ExerciseRecordResponse> response = healthRecordService.getExerciseRecordsForLast7Days(parentId).stream()
            .map(ExerciseRecordResponse::new)
            .toList();
        return ResponseEntity.ok(response);
    }
} 