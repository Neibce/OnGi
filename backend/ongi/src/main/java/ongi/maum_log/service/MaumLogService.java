package ongi.maum_log.service;

import java.net.URL;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.AllArgsConstructor;
import ongi.exception.EntityAlreadyExistException;
import ongi.family.entity.Family;
import ongi.family.repository.FamilyRepository;
import ongi.family.service.FamilyService;
import ongi.maum_log.dto.DateCount;
import ongi.maum_log.dto.MaumLogCalendarDto;
import ongi.maum_log.dto.MaumLogDto;
import ongi.maum_log.dto.MaumLogPresignedResponseDto;
import ongi.maum_log.dto.MaumLogUploadRequestDto;
import ongi.maum_log.dto.MaumLogsResponseDto;
import ongi.maum_log.entity.MaumLog;
import ongi.maum_log.repository.MaumLogRepository;
import ongi.security.CustomUserDetails;
import ongi.temperature.service.TemperatureService;
import ongi.user.entity.User;
import ongi.util.S3FileService;
import ongi.maum_log.dto.MaumLogResponseDto;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@AllArgsConstructor
public class MaumLogService {

    private static final String DIR_NAME = "maum-log-photos";

    private final S3FileService s3FileService;
    private final MaumLogRepository maumLogRepository;
    private final TemperatureService temperatureService;
    private final FamilyService familyService;
    private final FamilyRepository familyRepository;

    @Transactional
    public void createMaumLog(CustomUserDetails userDetails, MaumLogUploadRequestDto request) {
        if (!s3FileService.objectExists(DIR_NAME, request.frontFileName())
                || !s3FileService.objectExists(DIR_NAME, request.backFileName())) {
            throw new IllegalArgumentException("S3에 파일 존재하지 않음");
        }

        if (maumLogRepository.existsByFrontFileName(request.frontFileName())
                || maumLogRepository.existsByBackFileName(request.backFileName())) {
            throw new EntityAlreadyExistException("이미 업로드된 항목입니다");
        }

        MaumLog maumLog = MaumLog.builder()
                .frontFileName(request.frontFileName())
                .backFileName(request.backFileName())
                .emotions(request.emotions())
                .comment(request.comment())
                .location(request.location())
                .build();

        User user = userDetails.getUser();
        temperatureService.increaseTemperatureForEmotionUpload(user.getUuid(),
                familyService.getFamily(user).code());

        maumLogRepository.save(maumLog);
    }

    public MaumLogsResponseDto getMaumLog(CustomUserDetails userDetails, LocalDate date) {
        Family family = familyRepository.findByMembersContains(userDetails.getUser().getUuid())
                .orElseThrow(() -> new IllegalArgumentException("가족 정보를 찾을 수 없습니다."));

        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(23, 59, 59);

        boolean hasOwnUploaded = maumLogRepository.existsByCreatedByAndCreatedAtBetween(
                userDetails.getUser(), startOfDay, endOfDay);

        List<MaumLog> dateCounts = maumLogRepository.findByCreatedByUuidInAndCreatedAtBetween(
                family.getMembers(), startOfDay, endOfDay);

        List<MaumLogDto> maumLogDtos = dateCounts.stream().map(maumLog -> {
            URL frontFileUrl = s3FileService.createSignedGetUrl(DIR_NAME, maumLog.getFrontFileName());
            URL backFileUrl = s3FileService.createSignedGetUrl(DIR_NAME, maumLog.getBackFileName());
            return MaumLogDto.of(frontFileUrl, backFileUrl, maumLog);
        }).toList();

        return MaumLogsResponseDto.of(hasOwnUploaded, maumLogDtos);
    }


    public MaumLogCalendarDto getMaumLogCalendar(CustomUserDetails userDetails,
            YearMonth yearMonth) {
        Family family = familyRepository.findByMembersContains(userDetails.getUser().getUuid())
                .orElseThrow(() -> new IllegalArgumentException("가족 정보를 찾을 수 없습니다."));

        LocalDate startDate = yearMonth.atDay(1);
        LocalDate endDate = yearMonth.atEndOfMonth();

        List<DateCount> dateCounts = maumLogRepository.countDiariesPerDayByUsersAndMonth(
                family.getMembers(), startDate, yearMonth.atEndOfMonth());

        Map<LocalDate, Integer> result = dateCounts.stream()
                .collect(Collectors.toMap(DateCount::getDate, DateCount::getCount));

        Map<LocalDate, Integer> fullResult = new LinkedHashMap<>();
        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            fullResult.put(date, result.getOrDefault(date, 0));
        }

        return MaumLogCalendarDto.from(family.getMembers().size(), fullResult);
    }

    public MaumLogPresignedResponseDto getPresignedPutUrl(CustomUserDetails userDetails) {
        String frontFileName = UUID.randomUUID().toString();
        URL frontPresignedUrl = s3FileService.createSignedPutUrl(userDetails.getUser(), DIR_NAME,
                frontFileName);

        String backFileName = UUID.randomUUID().toString();
        URL backPresignedUrl = s3FileService.createSignedPutUrl(userDetails.getUser(), DIR_NAME,
                backFileName);

        return MaumLogPresignedResponseDto.from(
                frontFileName, frontPresignedUrl.toString(),
                backFileName, backPresignedUrl.toString()
        );
    }

    public List<MaumLogResponseDto> getAllMaumLogs() {
        return maumLogRepository.findAll().stream()
            .map(m -> new MaumLogResponseDto(
                m.getId(),
                m.getFileName(),
                m.getFileExtension(),
                m.getLocation(),
                m.getComment(),
                m.getEmotions()
            ))
            .toList();
    }
}
