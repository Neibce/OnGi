package ongi.health.repository;

import ongi.health.entity.PainRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface PainRecordRepository extends JpaRepository<PainRecord, Long> {
    // 최근 7일간 통증 기록 조회
    List<PainRecord> findByParentIdAndDateBetweenOrderByDateDesc(UUID parentId, LocalDate startDate, LocalDate endDate);
} 