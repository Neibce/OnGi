package ongi.health.repository;

import ongi.health.entity.ExerciseRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface ExerciseRecordRepository extends JpaRepository<ExerciseRecord, Long> {
    // 최근 7일간 운동 기록 조회
    List<ExerciseRecord> findByParentIdAndDateBetweenOrderByDateDesc(UUID parentId, LocalDate startDate, LocalDate endDate);
    // 특정 날짜의 통증 기록 조회
    java.util.Optional<ExerciseRecord> findByParentIdAndDate(UUID parentId, LocalDate date);
} 