package ongi.temperature.repository;

import ongi.temperature.entity.Temperature;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TemperatureRepository extends JpaRepository<Temperature, Long> {
    @Query("SELECT t FROM Temperature t WHERE t.familyId = :familyId")
    List<Temperature> findByFamilyId(@Param("familyId") String familyId);

    @Query("SELECT SUM(t.temperature) FROM Temperature t WHERE t.familyId = :familyId")
    Double getTotalTemperatureByFamilyId(@Param("familyId") String familyId);

    // 최근 5일간 가족 온도 총합 (날짜별)
    @Query("SELECT CAST(t.createdAt AS date), SUM(t.temperature) " +
            "FROM Temperature t WHERE t.familyId = :familyId AND t.createdAt >= :fromDate " +
            "GROUP BY CAST(t.createdAt AS date) ORDER BY CAST(t.createdAt AS date) DESC")
    List<Object[]> getFamilyTemperatureDailyRaw(@Param("familyId") String familyId, @Param("fromDate") java.time.LocalDateTime fromDate);

    // 최근 5일간 가족 구성원별 온도 기여 내역
    @Query("SELECT CAST(t.createdAt AS date), t.userId, SUM(t.temperature) " +
            "FROM Temperature t WHERE t.familyId = :familyId AND t.createdAt >= :fromDate " +
            "GROUP BY CAST(t.createdAt AS date), t.userId ORDER BY CAST(t.createdAt AS date) DESC")
    List<Object[]> getFamilyTemperatureContributionsRaw(@Param("familyId") String familyId, @Param("fromDate") java.time.LocalDateTime fromDate);

    // 오늘 해당 유저가 특정 활동(reason)으로 온도 기록을 남겼는지 확인 (날짜 기준)
    @Query("SELECT COUNT(t) > 0 FROM Temperature t WHERE t.userId = :userId AND t.familyId = :familyId AND t.reason = :reason AND FUNCTION('DATE', t.createdAt) = :date")
    boolean existsByUserIdAndFamilyIdAndReasonAndDate(@Param("userId") java.util.UUID userId, @Param("familyId") String familyId, @Param("reason") String reason, @Param("date") java.time.LocalDate date);

    // 최근 N일간 해당 유저가 가족 내에서 활동(온도 변화)이 있었는지
    @Query("SELECT COUNT(t) > 0 FROM Temperature t WHERE t.userId = :userId AND t.familyId = :familyId AND t.createdAt >= :since")
    boolean existsByUserIdAndFamilyIdAndCreatedAtAfter(@Param("userId") java.util.UUID userId, @Param("familyId") String familyId, @Param("since") java.time.LocalDateTime since);

    // 최근 N일간 가족 내에서 아무나 활동(온도 변화)이 있었는지
    @Query("SELECT COUNT(t) > 0 FROM Temperature t WHERE t.familyId = :familyId AND t.createdAt >= :since")
    boolean existsByFamilyIdAndCreatedAtAfter(@Param("familyId") String familyId, @Param("since") java.time.LocalDateTime since);
}