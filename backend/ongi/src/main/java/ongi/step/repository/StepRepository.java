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
    Integer getTotalStepsByFamilyAndDate(@Param("family") Family family,
            @Param("date") LocalDate date);

    @Query("""
                select
                    f.code   as familyCode,
                    f.name as familyName,
                    coalesce(sum(s.steps), 0) as totalSteps,
                    count(distinct m)      as memberCount
                from Family f
                left join f.members m
                left join Step s
                    on s.family = f
                   and s.date between :start and :end
                group by f.code, f.name
            """)
    List<FamilyStepsAndSizeView> findStepsAndSizeBetween(
            @Param("start") LocalDate start,
            @Param("end") LocalDate end
    );

    interface FamilyStepsAndSizeView {
        String getFamilyCode();
        String getFamilyName();
        Long getTotalSteps();
        Long getMemberCount();
    }
} 
