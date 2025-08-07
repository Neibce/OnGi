package ongi.pill.repository;

import ongi.pill.entity.Pill;
import ongi.pill.entity.PillIntakeRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface PillIntakeRecordRepository extends JpaRepository<PillIntakeRecord, Long> {

    List<PillIntakeRecord> findByPillInAndIntakeDate(List<Pill> pills, LocalDate intakeDate);
}