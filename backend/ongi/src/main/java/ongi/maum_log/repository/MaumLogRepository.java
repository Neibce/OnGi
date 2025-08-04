package ongi.maum_log.repository;

import ongi.maum_log.entity.MaumLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MaumLogRepository extends JpaRepository<MaumLog, Long> {

    boolean existsByFileName(String fileName);
}
