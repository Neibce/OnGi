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

    /**
 * Retrieves all Step entities for the specified family ID and date.
 *
 * @param familyId the identifier of the family
 * @param date the date for which steps are retrieved
 * @return a list of Step entities matching the given family ID and date
 */
List<Step> findByFamilyIdAndDate(String familyId, LocalDate date);

    /**
 * Retrieves an optional Step entity matching the specified family ID, user ID, and date.
 *
 * @param familyId the identifier of the family
 * @param userId the unique identifier of the user
 * @param date the date for which the step record is queried
 * @return an Optional containing the matching Step entity if found, or empty if not found
 */
Optional<Step> findByFamilyIdAndUserIdAndDate(String familyId, UUID userId, LocalDate date);

    /**
 * Returns the total number of steps recorded for a given family ID on a specific date.
 *
 * @param familyId the identifier of the family
 * @param date the date for which to calculate the total steps
 * @return the total steps for the specified family and date, or null if no records are found
 */
Integer getTotalStepsByFamilyIdAndDate(String familyId, LocalDate date);
} 