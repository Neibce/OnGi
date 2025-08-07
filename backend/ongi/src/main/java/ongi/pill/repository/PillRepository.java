package ongi.pill.repository;

import ongi.pill.entity.Pill;
import ongi.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PillRepository extends JpaRepository<Pill, Long> {

    List<Pill> findByOwner(User parent);
}