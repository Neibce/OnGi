package ongi.pill.repository;

import ongi.pill.entity.Pill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PillRepository extends JpaRepository<Pill, Long> {
    List<Pill> findByOwner(UUID owner);
    List<Pill> findByOwnerIn(List<UUID> owners);
} 