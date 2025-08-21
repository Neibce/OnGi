package ongi.maum_log.controller;

import jakarta.validation.Valid;
import java.time.LocalDate;
import java.time.YearMonth;
import lombok.AllArgsConstructor;
import ongi.maum_log.dto.MaumLogCalendarDto;
import ongi.maum_log.dto.MaumLogPresignedResponseDto;
import ongi.maum_log.dto.MaumLogUploadRequestDto;
import ongi.maum_log.dto.MaumLogsResponseDto;
import ongi.maum_log.service.MaumLogService;
import ongi.security.CustomUserDetails;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.Nullable;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import software.amazon.awssdk.http.HttpStatusCode;

@RestController
@RequestMapping("/maum-log")
@AllArgsConstructor
public class MaumLogController {

    private final MaumLogService maumLogService;

    @GetMapping("/presigned-url")
    public ResponseEntity<MaumLogPresignedResponseDto> getPresignedUrl(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(maumLogService.getPresignedPutUrl(userDetails));
    }

    @PostMapping
    public ResponseEntity<Void> createMaumLog(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody MaumLogUploadRequestDto request) {
        maumLogService.createMaumLog(userDetails, request);
        return ResponseEntity.status(HttpStatusCode.CREATED).build();
    }

    @GetMapping("/calendar")
    public ResponseEntity<MaumLogCalendarDto> getMaumLogCalendar(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam @Nullable YearMonth yearMonth) {
        if (yearMonth == null) {
            yearMonth = YearMonth.now();
        }
        MaumLogCalendarDto maumLogCalendarDto = maumLogService.getMaumLogCalendar(userDetails, yearMonth);
        return ResponseEntity.ok(maumLogCalendarDto);
    }

    @GetMapping
    public ResponseEntity<MaumLogsResponseDto> getMaumLogCalendar(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @RequestParam @Nullable LocalDate date) {
        if (date == null) {
            date = LocalDate.now();
        }
        MaumLogsResponseDto maumLogsResponseDto = maumLogService.getMaumLog(userDetails, date);
        return ResponseEntity.ok(maumLogsResponseDto);
    }

    @PostMapping("/reminder")
    public ResponseEntity<Void> sendMaumLogReminder(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        maumLogService.sendMaumLogReminder(userDetails.getUser());
        return ResponseEntity.status(HttpStatusCode.CREATED).build();
    }

}
