package ongi;

import ongi.health.controller.HealthRecordController;
import ongi.health.entity.PainRecord;
import ongi.health.entity.ExerciseRecord;
import ongi.health.service.HealthRecordService;
import ongi.health.dto.PainRecordResponse;
import ongi.health.dto.ExerciseRecordResponse;
import ongi.security.CustomUserDetails;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.BDDMockito.given;

@ExtendWith(MockitoExtension.class)
class HealthRecordControllerTest {

    @Mock
    private HealthRecordService healthRecordService;

    @InjectMocks
    private HealthRecordController healthRecordController;

    private UUID parentId;
    private CustomUserDetails userDetails;

    @BeforeEach
    void setUp() {
        parentId = UUID.randomUUID();
        userDetails = Mockito.mock(CustomUserDetails.class, Mockito.RETURNS_DEEP_STUBS);
        Mockito.when(userDetails.getUser().getUuid()).thenReturn(parentId);
    }

    @Test
    @DisplayName("통증 기록 추가 성공")
    void addPainRecord() {
        PainRecord record = PainRecord.builder()
                .id(1L)
                .parentId(parentId)
                .date(LocalDate.of(2024, 7, 18))
                .painArea(PainRecord.PainArea.HEAD)
                .painLevel(PainRecord.PainLevel.STRONG)
                .build();
        given(healthRecordService.addPainRecord(any(), any(), any(), any())).willReturn(record);

        PainRecordResponse response = healthRecordController.addPainRecord(
                userDetails,
                LocalDate.of(2024, 7, 18),
                PainRecord.PainArea.HEAD,
                PainRecord.PainLevel.STRONG
        ).getBody();

        assertNotNull(response);
        assertEquals(1L, response.id());
        assertEquals("HEAD", response.painArea());
        assertEquals("STRONG", response.painLevel());
    }

    @Test
    @DisplayName("운동 기록 추가 성공")
    void addExerciseRecord() {
        ExerciseRecord record = ExerciseRecord.builder()
                .id(1L)
                .parentId(parentId)
                .date(LocalDate.of(2024, 7, 18))
                .duration(60)
                .build();
        given(healthRecordService.addExerciseRecord(any(), any(), anyInt())).willReturn(record);

        ExerciseRecordResponse response = healthRecordController.addExerciseRecord(
                userDetails,
                LocalDate.of(2024, 7, 18),
                60
        ).getBody();

        assertNotNull(response);
        assertEquals(1L, response.id());
        assertEquals(60, response.duration());
    }

    @Test
    @DisplayName("통증 기록 최근 7일 조회")
    void getPainRecordsForLast7Days() {
        List<PainRecord> records = List.of(
                PainRecord.builder()
                        .id(1L)
                        .parentId(parentId)
                        .date(LocalDate.of(2024, 7, 18))
                        .painArea(PainRecord.PainArea.HEAD)
                        .painLevel(PainRecord.PainLevel.STRONG)
                        .build()
        );
        given(healthRecordService.getPainRecordsForLast7Days(any())).willReturn(records);

        List<PainRecordResponse> response = healthRecordController.getParentPainRecordsForLast7Days(parentId).getBody();

        assertNotNull(response);
        assertEquals(1, response.size());
        assertEquals("HEAD", response.get(0).painArea());
    }

    @Test
    @DisplayName("운동 기록 최근 7일 조회")
    void getExerciseRecordsForLast7Days() {
        List<ExerciseRecord> records = List.of(
                ExerciseRecord.builder()
                        .id(1L)
                        .parentId(parentId)
                        .date(LocalDate.of(2024, 7, 18))
                        .duration(60)
                        .build()
        );
        given(healthRecordService.getExerciseRecordsForLast7Days(any())).willReturn(records);

        List<ExerciseRecordResponse> response = healthRecordController.getParentExerciseRecordsForLast7Days(parentId).getBody();

        assertNotNull(response);
        assertEquals(1, response.size());
        assertEquals(60, response.get(0).duration());
    }
} 