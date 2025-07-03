package ongi.family.repository;

import java.util.Optional;
import java.util.UUID;
import ongi.family.entity.Family;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FamilyRepository extends JpaRepository<Family, String> {

    boolean existsByCode(String code);

    boolean existsByMembersContains(UUID memberId);

    Optional<Family> findByCode(String code);

    Optional<Family> findByMembersContains(UUID memberId);
}
