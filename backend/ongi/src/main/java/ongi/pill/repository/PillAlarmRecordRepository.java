package ongi.pill.repository;

import java.time.LocalDate;
import java.time.LocalTime;
import ongi.pill.entity.Pill;
import ongi.pill.entity.PillAlarmRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PillAlarmRecordRepository extends JpaRepository<PillAlarmRecord, Long> {

    boolean existsByPillAndAlarmDateAndAlarmTime(Pill pill, LocalDate alarmDate, LocalTime alarmTime);
    void deleteByPill(Pill pill);
}
