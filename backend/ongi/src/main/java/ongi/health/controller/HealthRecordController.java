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
import ongi.health.dto.ExerciseRecordWithDiffResponse;

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
    public ResponseEntity<ExerciseRecordWithDiffResponse> addExerciseRecord(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam int duration
    ) {
        ExerciseRecord record = healthRecordService.addExerciseRecord(userDetails.getUser().getUuid(), date, duration);
        // prevDuration, diff는 0으로 세팅 (추가 API에서는 증감 불필요)
        ExerciseRecordWithDiffResponse response = new ExerciseRecordWithDiffResponse(
            record.getId(), record.getDate(), record.getDuration(), 0, 0);
        return ResponseEntity.ok(response);
    }

    // 자녀용: 부모 통증 기록 조회 
    @GetMapping("/parents/pain")
    public ResponseEntity<List<PainRecordResponse>> getParentPainRecordsForChild(
            @RequestParam UUID parentId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        List<PainRecord> records = healthRecordService.getPainRecords(parentId, date);
        List<PainRecordResponse> response = records.stream()
            .map(PainRecordResponse::new)
            .toList();
        return ResponseEntity.ok(response);
    }

    // 자녀용: 부모 운동 기록 + 전날 대비 증감 조회
    @GetMapping("/parents/exercise")
    public ResponseEntity<ExerciseRecordWithDiffResponse> getParentExerciseRecordForChild(
            @RequestParam UUID parentId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        ExerciseRecordWithDiffResponse resp = healthRecordService.getExerciseRecordWithDiff(parentId, date);
        return ResponseEntity.ok(resp);
    }
} 