package ongi.maum_log.repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import ongi.maum_log.dto.DateCount;
import ongi.maum_log.entity.MaumLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface MaumLogRepository extends JpaRepository<MaumLog, Long> {

    boolean existsByFrontFileName(String fileName);
    boolean existsByBackFileName(String fileName);

    @Query(value = """
            SELECT DATE(created_at) AS date, COUNT(*) AS count
                FROM maum_log
                WHERE created_by_uuid IN (:usersUuid)
                  AND created_at BETWEEN :startDate AND :endDate
                GROUP BY DATE(created_at)
                ORDER BY date
            """, nativeQuery = true)
    List<DateCount> countDiariesPerDayByUsersAndMonth(
            @Param("usersUuid") List<UUID> users,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );
}
