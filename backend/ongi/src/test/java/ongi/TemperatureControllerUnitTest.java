package ongi;

import ongi.exception.EntityNotFoundException;
import ongi.temperature.controller.TemperatureController;
import ongi.temperature.dto.FamilyTemperatureDailyResponse;
import ongi.temperature.dto.FamilyTemperatureContributionResponse;
import ongi.temperature.service.TemperatureService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.context.ActiveProfiles;

import java.util.UUID;
import ongi.temperature.dto.FamilyTemperatureResponse;
import static org.mockito.BDDMockito.given;
import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
@ActiveProfiles("test")
class TemperatureControllerUnitTest {

    @Mock
    private TemperatureService temperatureService;

    @InjectMocks
    private TemperatureController temperatureController;

    private String testFamilyId;

    @BeforeEach
    void setUp() {
        testFamilyId = "FAM123";
    }

    @Test
    @DisplayName("가족 온도 요약 - 여러 가족, 구성원, 기여도 포함 성공")
    void getFamilyTemperatureSummary_MultipleFamiliesAndMembers_Success() {
        // given
        UUID userId1 = UUID.randomUUID();
        UUID userId2 = UUID.randomUUID();
        UUID userId3 = UUID.randomUUID();
        FamilyTemperatureResponse.MemberTemperatureInfo m1 = FamilyTemperatureResponse.MemberTemperatureInfo.builder()
            .userId(userId1).userName("홍길동").contributedTemperature(1.2).percentage(30.0).build();
        FamilyTemperatureResponse.MemberTemperatureInfo m2 = FamilyTemperatureResponse.MemberTemperatureInfo.builder()
            .userId(userId2).userName("김철수").contributedTemperature(2.8).percentage(70.0).build();
        FamilyTemperatureResponse.MemberTemperatureInfo m3 = FamilyTemperatureResponse.MemberTemperatureInfo.builder()
            .userId(userId3).userName("이영희").contributedTemperature(0.0).percentage(0.0).build();
        FamilyTemperatureResponse response = FamilyTemperatureResponse.builder()
            .familyTemperature(36.5)
            .totalContributedTemperature(4.0)
            .memberTemperatures(java.util.Arrays.asList(m1, m2, m3))
            .build();
        given(temperatureService.getFamilyTemperatureSummary(testFamilyId)).willReturn(response);

        // when
        FamilyTemperatureResponse result = temperatureController.getFamilyTemperatureSummary(testFamilyId).getBody();

        // then
        assertNotNull(result);
        assertEquals(36.5, result.getFamilyTemperature());
        assertEquals(4.0, result.getTotalContributedTemperature());
        assertEquals("홍길동", result.getMemberTemperatures().get(0).getUserName());
        assertEquals("김철수", result.getMemberTemperatures().get(1).getUserName());
        assertEquals("이영희", result.getMemberTemperatures().get(2).getUserName());
    }

    @Test
    @DisplayName("가족 온도 요약 - 존재하지 않는 가족")
    void getFamilyTemperatureSummary_FamilyNotFound() {
        // given
        given(temperatureService.getFamilyTemperatureSummary(testFamilyId))
            .willThrow(new EntityNotFoundException("가족을 찾을 수 없습니다."));

        // when & then
        assertThrows(EntityNotFoundException.class, () ->
            temperatureController.getFamilyTemperatureSummary(testFamilyId)
        );
    }

    @Test
    @DisplayName("가족 온도 일별 로그 - 여러 가족, 여러 일자 온도 로그 포함 성공")
    void getFamilyTemperatureDaily_MultipleFamiliesAndLogs_Success() {
        // given
        FamilyTemperatureDailyResponse.DailyTemperature daily1 = new FamilyTemperatureDailyResponse.DailyTemperature(
            java.time.LocalDate.now().minusDays(2), 36.6);
        FamilyTemperatureDailyResponse.DailyTemperature daily2 = new FamilyTemperatureDailyResponse.DailyTemperature(
            java.time.LocalDate.now().minusDays(1), 36.7);
        FamilyTemperatureDailyResponse.DailyTemperature daily3 = new FamilyTemperatureDailyResponse.DailyTemperature(
            java.time.LocalDate.now(), 36.8);
        FamilyTemperatureDailyResponse response = new FamilyTemperatureDailyResponse(
            java.util.Arrays.asList(daily1, daily2, daily3));
        given(temperatureService.getFamilyTemperatureDaily(testFamilyId)).willReturn(response);

        // when
        FamilyTemperatureDailyResponse result = temperatureController.getFamilyTemperatureDaily(testFamilyId).getBody();

        // then
        assertNotNull(result);
        assertEquals(3, result.getDailyTemperatures().size());
        assertEquals(36.6, result.getDailyTemperatures().get(0).getTotalTemperature());
        assertEquals(36.7, result.getDailyTemperatures().get(1).getTotalTemperature());
        assertEquals(36.8, result.getDailyTemperatures().get(2).getTotalTemperature());
    }

    @Test
    @DisplayName("가족 온도 일별 로그 - 존재하지 않는 가족")
    void getFamilyTemperatureDaily_FamilyNotFound() {
        // given
        given(temperatureService.getFamilyTemperatureDaily(testFamilyId))
            .willThrow(new EntityNotFoundException("가족을 찾을 수 없습니다."));

        // when & then
        assertThrows(EntityNotFoundException.class, () ->
            temperatureController.getFamilyTemperatureDaily(testFamilyId)
        );
    }

    @Test
    @DisplayName("가족 온도 기여도 - 여러 가족, 여러 구성원, 여러 일자 기여도 포함 성공")
    void getFamilyTemperatureContributions_MultipleFamiliesMembersLogs_Success() {
        // given
        java.util.UUID userId1 = java.util.UUID.randomUUID();
        java.util.UUID userId2 = java.util.UUID.randomUUID();
        FamilyTemperatureContributionResponse.Contribution c1 = new FamilyTemperatureContributionResponse.Contribution(
            java.time.LocalDate.now().minusDays(2), userId1, 1.1);
        FamilyTemperatureContributionResponse.Contribution c2 = new FamilyTemperatureContributionResponse.Contribution(
            java.time.LocalDate.now().minusDays(1), userId2, 2.2);
        FamilyTemperatureContributionResponse.Contribution c3 = new FamilyTemperatureContributionResponse.Contribution(
            java.time.LocalDate.now(), userId1, 3.3);
        FamilyTemperatureContributionResponse response = new FamilyTemperatureContributionResponse(
            java.util.Arrays.asList(c1, c2, c3));
        given(temperatureService.getFamilyTemperatureContributions(testFamilyId)).willReturn(response);

        // when
        FamilyTemperatureContributionResponse result = temperatureController.getFamilyTemperatureContributions(testFamilyId).getBody();

        // then
        assertNotNull(result);
        assertEquals(3, result.getContributions().size());
        assertEquals(1.1, result.getContributions().get(0).getContributed());
        assertEquals(2.2, result.getContributions().get(1).getContributed());
        assertEquals(3.3, result.getContributions().get(2).getContributed());
    }

    @Test
    @DisplayName("가족 온도 기여도 - 존재하지 않는 가족")
    void getFamilyTemperatureContributions_FamilyNotFound() {
        // given
        given(temperatureService.getFamilyTemperatureContributions(testFamilyId))
            .willThrow(new EntityNotFoundException("가족을 찾을 수 없습니다."));

        // when & then
        assertThrows(EntityNotFoundException.class, () ->
            temperatureController.getFamilyTemperatureContributions(testFamilyId)
        );
    }
}
