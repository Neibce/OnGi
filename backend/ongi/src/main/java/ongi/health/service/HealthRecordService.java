package ongi.health.service;

import lombok.RequiredArgsConstructor;
import ongi.health.entity.PainRecord;
import ongi.health.entity.ExerciseRecord;
import ongi.health.repository.PainRecordRepository;
import ongi.health.repository.ExerciseRecordRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class HealthRecordService {
    private final PainRecordRepository painRecordRepository;
    private final ExerciseRecordRepository exerciseRecordRepository;

    // 통증 기록 추가
    @Transactional
    public PainRecord addPainRecord(UUID parentId, LocalDate date, PainRecord.PainArea area, PainRecord.PainLevel level) {
        PainRecord record = PainRecord.builder()
                .parentId(parentId)
                .date(date)
                .painArea(area)
                .painLevel(level)
                .build();
        return painRecordRepository.save(record);
    }

    // 최근 7일간 통증 기록 조회
    public List<PainRecord> getParentPainRecordsForLast7Days(UUID parentId) {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(6); // 오늘 포함 7일
        return painRecordRepository.findByParentIdAndDateBetweenOrderByDateDesc(parentId, startDate, endDate);
    }



    // 운동 기록 추가/수정 (grid 기반)
    @Transactional
    public ExerciseRecord addOrUpdateExerciseRecord(UUID parentId, LocalDate date, String grid) {
        ExerciseRecord record = exerciseRecordRepository.findByParentIdAndDate(parentId, date)
                .orElse(ExerciseRecord.builder().parentId(parentId).date(date).build());
        record.setGrid(grid); // grid 저장 시 duration 자동 계산
        return exerciseRecordRepository.save(record);
    }

    // 최근 7일간 운동 기록 요약 조회 (duration만)
    public List<ExerciseRecord> getParentExerciseRecordsSummaryForLast7Days(UUID parentId) {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(6); // 오늘 포함 7일
        return exerciseRecordRepository.findByParentIdAndDateBetweenOrderByDateDesc(parentId, startDate, endDate);
    }

    // 특정 날짜 운동 기록 상세 조회 (grid+duration)
    public ExerciseRecord getParentExerciseRecordDetail(UUID parentId, LocalDate date) {
        return exerciseRecordRepository.findByParentIdAndDate(parentId, date)
                .orElse(null);
    }
} 