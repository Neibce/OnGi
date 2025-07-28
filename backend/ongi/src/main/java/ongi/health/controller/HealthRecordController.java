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
import ongi.family.service.FamilyService;
import ongi.family.dto.FamilyInfo;
import ongi.temperature.service.TemperatureService;

@RestController
@RequestMapping("/health")
@RequiredArgsConstructor
public class HealthRecordController {
    private final HealthRecordService healthRecordService;
    private final FamilyService familyService;
    private final TemperatureService temperatureService;

    // 통증 기록 추가
    @PostMapping("/pain")
    public ResponseEntity<PainRecordResponse> addPainRecord(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam PainRecord.PainArea area,
            @RequestParam PainRecord.PainLevel level
    ) {

        FamilyInfo familyInfo = familyService.getFamily(userDetails.getUser());
        String familyId = familyInfo.code();
        
        PainRecord record = healthRecordService.addPainRecord(userDetails.getUser().getUuid(), date, area, level);
        
        // 온도 상승
        temperatureService.increaseTemperatureForParentPainInput(userDetails.getUser().getUuid(), familyId);

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

        FamilyInfo familyInfo = familyService.getFamily(userDetails.getUser());
        String familyId = familyInfo.code();

        ExerciseRecord record = healthRecordService.addExerciseRecord(userDetails.getUser().getUuid(), date, duration);
        
        // 온도 상승
        temperatureService.increaseTemperatureForParentExerciseInput(userDetails.getUser().getUuid(), familyId);

        ExerciseRecordResponse response = new ExerciseRecordResponse(record);
        return ResponseEntity.ok(response);
    }

    // 최근 7일간 통증 기록 조회
    @GetMapping("/pain/view")
    public ResponseEntity<List<PainRecordResponse>> getParentPainRecordsForLast7Days(
            @RequestParam UUID parentId,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {

        FamilyInfo familyInfo = familyService.getFamily(userDetails.getUser());
        String familyId = familyInfo.code();

        // 온도 상승
        temperatureService.increaseTemperatureForChildPainView(userDetails.getUser().getUuid(), familyId);

        List<PainRecordResponse> response = healthRecordService.getParentPainRecordsForLast7Days(parentId).stream()
            .map(PainRecordResponse::new)
            .toList();
        return ResponseEntity.ok(response);
    }

    // 최근 7일간 운동 기록 조회
    @GetMapping("/exercise/view")
    public ResponseEntity<List<ExerciseRecordResponse>> getParentExerciseRecordsForLast7Days(
            @RequestParam UUID parentId,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {

        FamilyInfo familyInfo = familyService.getFamily(userDetails.getUser());
        String familyId = familyInfo.code();

        // 온도 상승
        temperatureService.increaseTemperatureForChildExerciseView(userDetails.getUser().getUuid(), familyId);

        List<ExerciseRecordResponse> response = healthRecordService.getParentExerciseRecordsForLast7Days(parentId).stream()
            .map(ExerciseRecordResponse::new)
            .toList();
        return ResponseEntity.ok(response);
    }
} 