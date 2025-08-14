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
import ongi.health.dto.ExerciseRecordSummaryResponse;

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
        
        // 여러 통증 부위를 한 번에 저장
        List<PainRecord.PainArea> painAreas = request.painArea().stream()
                .map(PainRecord.PainArea::valueOf)
                .toList();
        
        PainRecord record = healthRecordService.addOrUpdatePainRecord(
                userDetails.getUser().getUuid(),
                request.date(),
                painAreas
        );

        // 온도 상승
        temperatureService.increaseTemperatureForParentPainInput(userDetails.getUser().getUuid(), familyId);

        PainRecordResponse response = new PainRecordResponse(record);
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

        // 온도 상승: 자녀가 부모 정보를 조회할 때만
        if (!userDetails.getUser().getUuid().equals(parentId) && !userDetails.getUser().getIsParent()) {
            temperatureService.increaseTemperatureForChildPainView(userDetails.getUser().getUuid(), familyId);
        }

        List<PainRecordResponse> response = healthRecordService.getParentPainRecordsForLast7Days(parentId).stream()
                .map(PainRecordResponse::new)
                .toList();
        return ResponseEntity.ok(response);
    }



    // 운동 기록 추가(grid 기반)
    @PostMapping("/exercise/record")
    public ResponseEntity<ExerciseRecordResponse> addOrUpdateExerciseRecord(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestBody ExerciseRecordRequest request
    ) {
        FamilyInfo familyInfo = familyService.getFamily(userDetails.getUser());
        String familyId = familyInfo.code();
        ExerciseRecord record = healthRecordService.addOrUpdateExerciseRecord(
                userDetails.getUser().getUuid(),
                request.date(),
                request.grid() // 2차원 배열로 전달
        );
        temperatureService.increaseTemperatureForParentExerciseInput(userDetails.getUser().getUuid(), familyId);
        ExerciseRecordResponse response = new ExerciseRecordResponse(record);
        return ResponseEntity.ok(response);
    }

    // 최근 7일간 운동 기록 요약 조회 (기본페이지)
    @GetMapping("/exercise/summary")
    public ResponseEntity<List<ExerciseRecordSummaryResponse>> getParentExerciseRecordsSummaryForLast7Days(
            @RequestParam UUID parentId,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        FamilyInfo familyInfo = familyService.getFamily(userDetails.getUser());
        String familyId = familyInfo.code();

        // 온도 상승: 자녀가 부모 정보를 조회할 때만
        if (!userDetails.getUser().getUuid().equals(parentId) && !userDetails.getUser().getIsParent()) {
            temperatureService.increaseTemperatureForChildExerciseView(userDetails.getUser().getUuid(), familyId);
        }

        List<ExerciseRecordSummaryResponse> response = healthRecordService.getParentExerciseRecordsSummaryForLast7Days(parentId).stream()
                .map(ExerciseRecordSummaryResponse::new)
                .toList();
        return ResponseEntity.ok(response);
    }

    // 특정 날짜 운동 기록 상세 조회 (상세페이지)
    @GetMapping("/exercise/detail")
    public ResponseEntity<ExerciseRecordResponse> getParentExerciseRecordDetail(
            @RequestParam UUID parentId,
            @RequestParam String date,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        ExerciseRecord record = healthRecordService.getParentExerciseRecordDetail(parentId, java.time.LocalDate.parse(date));
        if (record == null) return ResponseEntity.notFound().build();
        ExerciseRecordResponse response = new ExerciseRecordResponse(record);
        return ResponseEntity.ok(response);
    }

}