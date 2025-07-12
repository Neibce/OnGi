package ongi;

import com.fasterxml.jackson.databind.ObjectMapper;
import ongi.exception.EntityNotFoundException;
import ongi.step.controller.StepController;
import ongi.step.dto.FamilyStepResponse;
import ongi.step.dto.StepUpsertRequest;
import ongi.step.service.StepService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import ongi.exception.GlobalExceptionHandler;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@ExtendWith(MockitoExtension.class)
class StepControllerUnitTest {

    @Mock
    private StepService stepService;

    @InjectMocks
    private StepController stepController;

    private MockMvc mockMvc;
    private ObjectMapper objectMapper;

    private UUID testUserId;
    private StepUpsertRequest validRequest;
    private FamilyStepResponse familyStepResponse;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(stepController)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();
        objectMapper = new ObjectMapper();
        
        testUserId = UUID.fromString("550e8400-e29b-41d4-a716-446655440000");
        validRequest = StepUpsertRequest.builder()
                .steps(5000)
                .build();

        familyStepResponse = FamilyStepResponse.builder()
                .totalSteps(15000)
                .date(LocalDate.now())
                .memberSteps(Arrays.asList(
                        FamilyStepResponse.MemberStepInfo.builder()
                                .userId(testUserId)
                                .userName("홍길동")
                                .steps(5000)
                                .build(),
                        FamilyStepResponse.MemberStepInfo.builder()
                                .userId(UUID.randomUUID())
                                .userName("김철수")
                                .steps(10000)
                                .build()
                ))
                .build();
    }

    @Test
    @DisplayName("POST /steps - 걸음 수 업데이트 성공")
    void upsertStep_Success() throws Exception {
        // given
        doNothing().when(stepService).upsertStep(any(UUID.class), any(StepUpsertRequest.class));

        // when & then
        mockMvc.perform(post("/steps")
                        .principal(createAuthentication())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(validRequest)))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("POST /steps - 유효하지 않은 걸음 수 (음수)")
    void upsertStep_InvalidSteps_Negative() throws Exception {
        // given
        StepUpsertRequest invalidRequest = StepUpsertRequest.builder()
                .steps(-100)
                .build();

        // when & then
        mockMvc.perform(post("/steps")
                        .principal(createAuthentication())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("POST /steps - 존재하지 않는 사용자")
    void upsertStep_UserNotFound() throws Exception {
        // given
        doThrow(new EntityNotFoundException("사용자를 찾을 수 없습니다."))
                .when(stepService).upsertStep(any(UUID.class), any(StepUpsertRequest.class));

        // when & then
        mockMvc.perform(post("/steps")
                        .principal(createAuthentication())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(validRequest)))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("GET /steps - 가족 걸음 수 조회 성공")
    void getFamilySteps_Success() throws Exception {
        // given
        given(stepService.getFamilySteps(any(UUID.class)))
                .willReturn(familyStepResponse);

        // when & then
        mockMvc.perform(get("/steps")
                        .principal(createAuthentication()))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.totalSteps").value(15000))
                .andExpect(jsonPath("$.memberSteps[0].userName").value("홍길동"))
                .andExpect(jsonPath("$.memberSteps[0].steps").value(5000));
    }

    @Test
    @DisplayName("GET /steps - 존재하지 않는 사용자")
    void getFamilySteps_UserNotFound() throws Exception {
        // given
        given(stepService.getFamilySteps(any(UUID.class)))
                .willThrow(new EntityNotFoundException("사용자를 찾을 수 없습니다."));

        // when & then
        mockMvc.perform(get("/steps")
                        .principal(createAuthentication()))
                .andExpect(status().isNotFound());
    }

    private Authentication createAuthentication() {
        return new UsernamePasswordAuthenticationToken(testUserId.toString(), null);
    }
} 