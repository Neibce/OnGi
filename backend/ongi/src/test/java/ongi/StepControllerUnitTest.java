package ongi;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import ongi.exception.EntityNotFoundException;
import ongi.security.CustomUserDetails;
import ongi.step.controller.StepController;
import ongi.step.dto.FamilyStepResponse;
import ongi.step.dto.StepUpsertRequest;
import ongi.step.service.StepService;
import ongi.user.entity.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.ResponseEntity;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.springframework.http.HttpStatus.OK;

@ExtendWith(MockitoExtension.class)
class StepControllerUnitTest {

    @Mock
    private StepService stepService;

    @InjectMocks
    private StepController stepController;

    private Validator validator;
    private UUID testUserId;
    private CustomUserDetails customUserDetails;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
        
        testUserId = UUID.randomUUID();
        User testUser = User.builder()
                .uuid(testUserId)
                .email("test@example.com")
                .password("password")
                .name("홍길동")
                .isParent(true)
                .build();
        customUserDetails = new CustomUserDetails(testUser);
    }

    @Nested
    @DisplayName("걸음 수 업데이트 테스트")
    class UpsertStepTest {

        @Test
        @DisplayName("성공 - 유효한 걸음 수로 업데이트")
        void upsertStep_Success() {
            // given
            StepUpsertRequest request = new StepUpsertRequest(5000);
            doNothing().when(stepService).upsertStep(any(UUID.class), any(StepUpsertRequest.class));

            // when
            ResponseEntity<Void> response = stepController.upsertStep(request, customUserDetails);

            // then
            assertThat(response.getStatusCode()).isEqualTo(OK);
            verify(stepService).upsertStep(testUserId, request);
        }

        @Test
        @DisplayName("실패 - 존재하지 않는 사용자")
        void upsertStep_UserNotFound() {
            // given
            StepUpsertRequest request = new StepUpsertRequest(5000);
            doThrow(new EntityNotFoundException("사용자를 찾을 수 없습니다."))
                    .when(stepService).upsertStep(any(UUID.class), any(StepUpsertRequest.class));

            // when & then
            assertThrows(EntityNotFoundException.class, () -> 
                stepController.upsertStep(request, customUserDetails)
            );
        }

        @Test
        @DisplayName("실패 - 음수 걸음 수")
        void upsertStep_InvalidSteps_Negative() {
            // given
            StepUpsertRequest request = new StepUpsertRequest(-100);

            // when
            Set<ConstraintViolation<StepUpsertRequest>> violations = validator.validate(request);

            // then
            assertThat(violations).hasSize(1);
            assertThat(violations.iterator().next().getMessage()).isEqualTo("걸음 수는 0 이상이어야 합니다.");
        }

        @Test
        @DisplayName("실패 - null 걸음 수")
        void upsertStep_NullSteps() {
            // given
            StepUpsertRequest request = new StepUpsertRequest(null);

            // when
            Set<ConstraintViolation<StepUpsertRequest>> violations = validator.validate(request);

            // then
            assertThat(violations).hasSize(1);
            assertThat(violations.iterator().next().getMessage()).isEqualTo("걸음 수는 필수입니다.");
        }
    }

    @Nested
    @DisplayName("가족 걸음 수 조회 테스트")
    class GetFamilyStepsTest {

        @Test
        @DisplayName("성공 - 가족 걸음 수 조회")
        void getFamilySteps_Success() {
            // given
            FamilyStepResponse expectedResponse = new FamilyStepResponse(
                    15000,
                    LocalDate.now(),
                    Arrays.asList(
                            new FamilyStepResponse.MemberStepInfo(testUserId, "홍길동", 5000),
                            new FamilyStepResponse.MemberStepInfo(UUID.randomUUID(), "김철수", 10000)
                    )
            );
            given(stepService.getFamilySteps(testUserId)).willReturn(expectedResponse);

            // when
            ResponseEntity<FamilyStepResponse> response = stepController.getFamilySteps(customUserDetails);

            // then
            assertThat(response.getStatusCode()).isEqualTo(OK);
            assertThat(response.getBody()).isNotNull();
            assertThat(response.getBody().totalSteps()).isEqualTo(15000);
            assertThat(response.getBody().memberSteps()).hasSize(2);
            verify(stepService).getFamilySteps(testUserId);
        }

        @Test
        @DisplayName("실패 - 존재하지 않는 사용자")
        void getFamilySteps_UserNotFound() {
            // given
            given(stepService.getFamilySteps(testUserId))
                    .willThrow(new EntityNotFoundException("사용자를 찾을 수 없습니다."));

            // when & then
            assertThrows(EntityNotFoundException.class, () -> 
                stepController.getFamilySteps(customUserDetails)
            );
        }
    }
}
