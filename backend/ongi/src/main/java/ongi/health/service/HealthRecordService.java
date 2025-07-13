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
import java.util.Optional;
import java.util.UUID;
import ongi.health.dto.ExerciseRecordWithDiffResponse;

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

    // 통증 기록 조회 (날짜별)
    public List<PainRecord> getPainRecords(UUID parentId, LocalDate date) {
        return painRecordRepository.findByParentIdAndDate(parentId, date);
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

    // 운동 기록 조회 (날짜별)
    public Optional<ExerciseRecord> getExerciseRecord(UUID parentId, LocalDate date) {
        return exerciseRecordRepository.findByParentIdAndDate(parentId, date);
    }

    // 오늘+전날 운동 기록 및 증감량을 한 번에 반환
    public ExerciseRecordWithDiffResponse getExerciseRecordWithDiff(UUID parentId, LocalDate date) {
        ExerciseRecord today = exerciseRecordRepository.findByParentIdAndDate(parentId, date).orElse(null);
        ExerciseRecord prev = exerciseRecordRepository.findByParentIdAndDate(parentId, date.minusDays(1)).orElse(null);
        int prevDuration = prev != null ? prev.getDuration() : 0;
        int todayDuration = today != null ? today.getDuration() : 0;
        int diff = todayDuration - prevDuration;
        return new ExerciseRecordWithDiffResponse(today, prevDuration, diff);
    }
} 