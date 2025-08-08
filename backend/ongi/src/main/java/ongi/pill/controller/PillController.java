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
import ongi.family.service.FamilyService;
import ongi.family.dto.FamilyInfo;
import ongi.temperature.service.TemperatureService;

@RestController
@RequestMapping("/pills")
@RequiredArgsConstructor
public class PillController {

    private final PillService pillService;
    private final FamilyService familyService;
    private final TemperatureService temperatureService;

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

        // 온도 상승: 부모 약 복용 기록 시
        FamilyInfo familyInfo = familyService.getFamily(userDetails.getUser());
        String familyId = familyInfo.code();
        temperatureService.increaseTemperatureForParentMedInput(userDetails.getUser().getUuid(), familyId);

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

        // 온도 상승: 자녀가 부모의 약을 조회할 때만
        if (parentUuid != null && !userDetails.getUser().getUuid().equals(parentUuid) && !userDetails.getUser().getIsParent()) {
            FamilyInfo familyInfo = familyService.getFamily(userDetails.getUser());
            String familyId = familyInfo.code();
            temperatureService.increaseTemperatureForChildMedView(userDetails.getUser().getUuid(), familyId);
        }

        List<PillInfoWithIntakeStatus> pills = pillService.getFamilyPills(userDetails.getUser(), parentUuid, date);
        return ResponseEntity.ok(pills);
    }
}
