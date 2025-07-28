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

    // 운동 기록 추가
    @Transactional
    public ExerciseRecord addExerciseRecord(UUID parentId, LocalDate date, int duration) {
        ExerciseRecord record = ExerciseRecord.builder()
                .parentId(parentId)
                .date(date)
                .duration(duration)
                .build();
        return exerciseRecordRepository.save(record);
    }

    // 최근 7일간 통증 기록 조회
    public List<PainRecord> getParentPainRecordsForLast7Days(UUID parentId) {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(6); // 오늘 포함 7일
        return painRecordRepository.findByParentIdAndDateBetweenOrderByDateDesc(parentId, startDate, endDate);
    }

    // 최근 7일간 운동 기록 조회
    public List<ExerciseRecord> getParentExerciseRecordsForLast7Days(UUID parentId) {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(6); // 오늘 포함 7일
        return exerciseRecordRepository.findByParentIdAndDateBetweenOrderByDateDesc(parentId, startDate, endDate);
    }
} 