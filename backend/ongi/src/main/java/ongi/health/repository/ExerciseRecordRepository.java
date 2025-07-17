package ongi.health.repository;

import ongi.health.entity.ExerciseRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ExerciseRecordRepository extends JpaRepository<ExerciseRecord, Long> {
    Optional<ExerciseRecord> findByParentIdAndDate(UUID parentId, LocalDate date);
    List<ExerciseRecord> findByParentId(UUID parentId);
} 