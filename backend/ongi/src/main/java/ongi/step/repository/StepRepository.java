package ongi.step.repository;

import ongi.step.entity.Step;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface StepRepository extends JpaRepository<Step, Long> {

    List<Step> findByFamilyIdAndDate(String familyId, LocalDate date);

    Optional<Step> findByFamilyIdAndUserIdAndDate(String familyId, UUID userId, LocalDate date);

    Integer getTotalStepsByFamilyIdAndDate(String familyId, LocalDate date);
} 
