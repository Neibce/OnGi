package ongi;

import java.util.Collections;
import ongi.exception.EntityNotFoundException;
import ongi.exception.GlobalExceptionHandler;
import ongi.temperature.controller.TemperatureController;
import ongi.temperature.dto.FamilyTemperatureResponse;
import ongi.temperature.dto.FamilyTemperatureResponse.MemberTemperatureInfo;
import ongi.temperature.dto.MemberTemperatureResponse;
import ongi.temperature.dto.MemberTemperatureResponse.TemperatureRecord;
import ongi.temperature.service.TemperatureService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.time.LocalDateTime;
import java.util.UUID;

import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@ExtendWith(MockitoExtension.class)
class TemperatureControllerUnitTest {

    @Mock
    private TemperatureService temperatureService;

    @InjectMocks
    private TemperatureController temperatureController;

    private MockMvc mockMvc;
    private String testFamilyId;
    private UUID testUserId;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(temperatureController)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();

        testFamilyId = "FAM123";
        testUserId = UUID.randomUUID();
    }

    @Test
    @DisplayName("GET /api/temperatures/family/{familyId} - 가족 온도 조회 성공")
    void getFamilyTemperature_Success() throws Exception {
        // given
        FamilyTemperatureResponse response = FamilyTemperatureResponse.builder()
                .familyTemperature(36.8)
                .totalContributedTemperature(73.6)
                .memberTemperatures(Collections.singletonList(
                        MemberTemperatureInfo.builder()
                                .userId(testUserId)
                                .userName("홍길동")
                                .contributedTemperature(36.8)
                                .percentage(50.0)
                                .build()
                ))
                .build();
        given(temperatureService.getFamilyTemperature(testFamilyId)).willReturn(response);

        // when & then
        mockMvc.perform(get("/api/temperatures/family/{familyId}", testFamilyId))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.familyTemperature").value(36.8))
                .andExpect(jsonPath("$.totalContributedTemperature").value(73.6))
                .andExpect(jsonPath("$.memberTemperatures[0].userName").value("홍길동"));
    }

    @Test
    @DisplayName("GET /api/temperatures/family/{familyId} - 존재하지 않는 가족")
    void getFamilyTemperature_FamilyNotFound() throws Exception {
        // given
        given(temperatureService.getFamilyTemperature(testFamilyId))
                .willThrow(new EntityNotFoundException("가족을 찾을 수 없습니다."));

        // when & then
        mockMvc.perform(get("/api/temperatures/family/{familyId}", testFamilyId))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("GET /api/temperatures/family/{familyId}/member/{userId} - 개인별 온도 조회 성공")
    void getMemberTemperature_Success() throws Exception {
        // given
        MemberTemperatureResponse response = MemberTemperatureResponse.builder()
                .userId(testUserId)
                .userName("홍길동")
                .contributedTemperature(36.8)
                .percentage(50.0)
                .temperatureRecords(Collections.singletonList(
                        TemperatureRecord.builder()
                                .temperatureId(1L)
                                .temperature(1.5)
                                .activity("밥 먹기")
                                .createdAt(LocalDateTime.now())
                                .build()
                ))
                .build();
        given(temperatureService.getMemberTemperature(testFamilyId, testUserId)).willReturn(response);

        // when & then
        mockMvc.perform(get("/api/temperatures/family/{familyId}/member/{userId}", testFamilyId, testUserId))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.userId").value(testUserId.toString()))
                .andExpect(jsonPath("$.userName").value("홍길동"))
                .andExpect(jsonPath("$.contributedTemperature").value(36.8))
                .andExpect(jsonPath("$.temperatureRecords[0].activity").value("밥 먹기"));
    }

    @Test
    @DisplayName("GET /api/temperatures/family/{familyId}/member/{userId} - 존재하지 않는 사용자")
    void getMemberTemperature_UserNotFound() throws Exception {
        // given
        given(temperatureService.getMemberTemperature(testFamilyId, testUserId))
                .willThrow(new EntityNotFoundException("사용자를 찾을 수 없습니다."));

        // when & then
        mockMvc.perform(get("/api/temperatures/family/{familyId}/member/{userId}", testFamilyId, testUserId))
                .andExpect(status().isNotFound());
    }
}
