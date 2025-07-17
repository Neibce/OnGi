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

    // 최근 5일간 가족 온도 총합 (날짜별) - Object[]로 반환
    @Query("SELECT CAST(t.createdAt AS date), SUM(t.temperature) " +
            "FROM Temperature t WHERE t.familyId = :familyId AND t.createdAt >= :fromDate " +
            "GROUP BY CAST(t.createdAt AS date) ORDER BY CAST(t.createdAt AS date) DESC")
    List<Object[]> getFamilyTemperatureDailyRaw(@Param("familyId") String familyId, @Param("fromDate") java.time.LocalDateTime fromDate);

    // 최근 5일간 가족 구성원별 온도 기여 내역 - Object[]로 반환
    @Query("SELECT CAST(t.createdAt AS date), t.userId, SUM(t.temperature) " +
            "FROM Temperature t WHERE t.familyId = :familyId AND t.createdAt >= :fromDate " +
            "GROUP BY CAST(t.createdAt AS date), t.userId ORDER BY CAST(t.createdAt AS date) DESC")
    List<Object[]> getFamilyTemperatureContributionsRaw(@Param("familyId") String familyId, @Param("fromDate") java.time.LocalDateTime fromDate);
} 