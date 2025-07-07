package ongi.temperature.repository;

import ongi.temperature.entity.Temperature;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TemperatureRepository extends JpaRepository<Temperature, Long> {
    
    @Query("SELECT t FROM Temperature t WHERE t.familyId = :familyId")
    List<Temperature> findByFamilyId(@Param("familyId") String familyId);
    
    @Query("SELECT t FROM Temperature t WHERE t.familyId = :familyId AND t.userId = :userId")
    List<Temperature> findByFamilyIdAndUserId(@Param("familyId") String familyId, @Param("userId") UUID userId);
    
    @Query("SELECT SUM(t.temperature) FROM Temperature t WHERE t.familyId = :familyId")
    Double getTotalTemperatureByFamilyId(@Param("familyId") String familyId);
    
    @Query("SELECT SUM(t.temperature) FROM Temperature t WHERE t.familyId = :familyId AND t.userId = :userId")
    Double getTotalTemperatureByFamilyIdAndUserId(@Param("familyId") String familyId, @Param("userId") UUID userId);
} 