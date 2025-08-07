package ongi.step.repository;

import ongi.family.entity.Family;
import ongi.step.entity.Step;
import ongi.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface StepRepository extends JpaRepository<Step, Long> {

    List<Step> findByFamilyAndDate(Family family, LocalDate date);

    Optional<Step> findByCreatedByAndDate(User user, LocalDate date);

    @Query("SELECT IFNULL(SUM(s.steps), 0) FROM Step s WHERE s.family = :family AND s.date = :date")
    Integer getTotalStepsByFamilyAndDate(@Param("family") Family family, @Param("date") LocalDate date);

    List<Step> findByFamilyAndDateBetween(Family family, LocalDate startDate, LocalDate endDate);

    List<Integer> getTotalStepsByDateBetween(LocalDate startDate, LocalDate endDate);

    List<Step> findByFamily(Family family);
} 
