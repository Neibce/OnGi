package ongi.health.repository;

import ongi.health.entity.PainRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface PainRecordRepository extends JpaRepository<PainRecord, Long> {
    List<PainRecord> findByParentIdAndDate(UUID parentId, LocalDate date);
    List<PainRecord> findByParentId(UUID parentId);
} 