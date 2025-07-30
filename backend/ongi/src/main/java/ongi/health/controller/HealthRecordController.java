package ongi.health.controller;

import lombok.RequiredArgsConstructor;
import ongi.health.entity.PainRecord;
import ongi.health.entity.ExerciseRecord;
import ongi.health.service.HealthRecordService;
import ongi.security.CustomUserDetails;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import ongi.health.dto.PainRecordResponse;
import ongi.health.dto.ExerciseRecordResponse;
import ongi.family.service.FamilyService;
import ongi.family.dto.FamilyInfo;
import ongi.temperature.service.TemperatureService;
import ongi.health.dto.PainRecordRequest;
import ongi.health.dto.ExerciseRecordRequest;

@RestController
@RequestMapping("/health")
@RequiredArgsConstructor
public class HealthRecordController {
    private final HealthRecordService healthRecordService;
    private final FamilyService familyService;
    private final TemperatureService temperatureService;

    // 통증 기록 추가
    @PostMapping("/pain/record")
    public ResponseEntity<PainRecordResponse> addPainRecord(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody PainRecordRequest request
    ) {

        FamilyInfo familyInfo = familyService.getFamily(userDetails.getUser());
        String familyId = familyInfo.code();
        
        PainRecord record = healthRecordService.addPainRecord(
                userDetails.getUser().getUuid(),
                request.date(),
                PainRecord.PainArea.valueOf(request.painArea()),
                PainRecord.PainLevel.valueOf(request.painLevel())
        );
        
        // 온도 상승
        temperatureService.increaseTemperatureForParentPainInput(userDetails.getUser().getUuid(), familyId);

        PainRecordResponse response = new PainRecordResponse(record);
        return ResponseEntity.ok(response);
    }

    // 운동 기록 추가
    @PostMapping("/exercise/record")
    public ResponseEntity<ExerciseRecordResponse> addExerciseRecord(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody ExerciseRecordRequest request
    ) {

        FamilyInfo familyInfo = familyService.getFamily(userDetails.getUser());
        String familyId = familyInfo.code();

        ExerciseRecord record = healthRecordService.addExerciseRecord(
                userDetails.getUser().getUuid(),
                request.date(),
                request.duration()
        );
        
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