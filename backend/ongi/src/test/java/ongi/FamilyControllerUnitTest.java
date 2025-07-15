package ongi;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import ongi.exception.EntityNotFoundException;
import ongi.family.controller.FamilyController;
import ongi.family.dto.FamilyCreateRequest;
import ongi.family.dto.FamilyInfo;
import ongi.family.dto.FamilyJoinRequest;
import ongi.family.service.FamilyService;
import ongi.security.CustomUserDetails;
import ongi.user.dto.UserInfo;
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

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;

@ExtendWith(MockitoExtension.class)
class FamilyControllerUnitTest {

    @Mock
    private FamilyService familyService;

    @InjectMocks
    private FamilyController familyController;

    private Validator validator;
    private CustomUserDetails customUserDetails;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();

        User testUser = User.builder()
                .uuid(UUID.randomUUID())
                .email("test@example.com")
                .password("password")
                .name("홍길동")
                .isParent(true)
                .build();
        customUserDetails = new CustomUserDetails(testUser);
    }

    @Nested
    @DisplayName("가족 정보 조회 테스트")
    class GetFamilyInfoTest {

        @Test
        @DisplayName("성공 - 가족 정보 조회")
        void getFamilyInfo_Success() {
            // given
            FamilyInfo expectedFamilyInfo = new FamilyInfo(
                    "FAM123",
                    "홍길동의 가족",
                    3,
                    LocalDateTime.now(),
                    LocalDateTime.now()
            );
            given(familyService.getFamily(customUserDetails.getUser())).willReturn(expectedFamilyInfo);

            // when
            ResponseEntity<FamilyInfo> response = familyController.getFamilyInfo(customUserDetails);

            // then
            assertThat(response.getStatusCode().value()).isEqualTo(200);
            assertThat(response.getBody()).isNotNull();
            assertThat(response.getBody().code()).isEqualTo("FAM123");
            assertThat(response.getBody().name()).isEqualTo("홍길동의 가족");
            assertThat(response.getBody().memberCount()).isEqualTo(3);
        }

        @Test
        @DisplayName("실패 - 가족이 존재하지 않음")
        void getFamilyInfo_FamilyNotFound() {
            // given
            given(familyService.getFamily(customUserDetails.getUser()))
                    .willThrow(new EntityNotFoundException("가족을 찾을 수 없습니다."));

            // when & then
            assertThrows(EntityNotFoundException.class, () -> 
                familyController.getFamilyInfo(customUserDetails)
            );
        }
    }

    @Nested
    @DisplayName("가족 멤버 목록 조회 테스트")
    class GetFamilyMembersTest {

        @Test
        @DisplayName("성공 - 가족 멤버 목록 조회")
        void getFamilyMembers_Success() {
            // given
            List<UserInfo> expectedMembers = Arrays.asList(
                    new UserInfo(UUID.randomUUID(), "test@example.com", "홍길동", true, LocalDateTime.now(), LocalDateTime.now()),
                    new UserInfo(UUID.randomUUID(), "member@example.com", "김철수", false, LocalDateTime.now(), LocalDateTime.now())
            );
            given(familyService.getFamilyMembers(customUserDetails.getUser())).willReturn(expectedMembers);

            // when
            ResponseEntity<List<UserInfo>> response = familyController.getFamilyMembers(customUserDetails);

            // then
            assertThat(response.getStatusCode().value()).isEqualTo(200);
            assertThat(response.getBody()).isNotNull();
            assertThat(response.getBody()).hasSize(2);
            assertThat(response.getBody().get(0).name()).isEqualTo("홍길동");
            assertThat(response.getBody().get(1).name()).isEqualTo("김철수");
        }

        @Test
        @DisplayName("실패 - 가족이 존재하지 않음")
        void getFamilyMembers_FamilyNotFound() {
            // given
            given(familyService.getFamilyMembers(customUserDetails.getUser()))
                    .willThrow(new EntityNotFoundException("가족을 찾을 수 없습니다."));

            // when & then
            assertThrows(EntityNotFoundException.class, () -> 
                familyController.getFamilyMembers(customUserDetails)
            );
        }
    }

    @Nested
    @DisplayName("가족 생성 테스트")
    class CreateFamilyTest {

        @Test
        @DisplayName("성공 - 가족 생성")
        void createFamily_Success() {
            // given
            FamilyCreateRequest request = new FamilyCreateRequest("홍길동의 가족");
            FamilyInfo expectedFamilyInfo = new FamilyInfo(
                    "FAM123",
                    "홍길동의 가족",
                    1,
                    LocalDateTime.now(),
                    LocalDateTime.now()
            );
            given(familyService.createFamily(eq(customUserDetails.getUser()), any(FamilyCreateRequest.class)))
                    .willReturn(expectedFamilyInfo);

            // when
            ResponseEntity<FamilyInfo> response = familyController.createFamily(customUserDetails, request);

            // then
            assertThat(response.getStatusCode().value()).isEqualTo(201);
            assertThat(response.getBody()).isNotNull();
            assertThat(response.getBody().code()).isEqualTo("FAM123");
            assertThat(response.getBody().name()).isEqualTo("홍길동의 가족");
            assertThat(response.getBody().memberCount()).isEqualTo(1);
        }

        @Test
        @DisplayName("실패 - 가족 이름이 빈 값")
        void createFamily_BlankName() {
            // given
            FamilyCreateRequest request = new FamilyCreateRequest("");

            // when
            Set<ConstraintViolation<FamilyCreateRequest>> violations = validator.validate(request);

            // then
            assertThat(violations).hasSize(1);
            assertThat(violations.iterator().next().getMessage()).isEqualTo("가족 이름은 필수입니다.");
        }

        @Test
        @DisplayName("실패 - 가족 이름이 null")
        void createFamily_NullName() {
            // given
            FamilyCreateRequest request = new FamilyCreateRequest(null);

            // when
            Set<ConstraintViolation<FamilyCreateRequest>> violations = validator.validate(request);

            // then
            assertThat(violations).hasSize(1);
            assertThat(violations.iterator().next().getMessage()).isEqualTo("가족 이름은 필수입니다.");
        }
    }

    @Nested
    @DisplayName("가족 가입 테스트")
    class JoinFamilyTest {

        @Test
        @DisplayName("성공 - 가족 가입")
        void joinFamily_Success() {
            // given
            FamilyJoinRequest request = new FamilyJoinRequest("FAM123");
            FamilyInfo expectedFamilyInfo = new FamilyInfo(
                    "FAM123",
                    "홍길동의 가족",
                    2,
                    LocalDateTime.now(),
                    LocalDateTime.now()
            );
            given(familyService.joinFamily(eq(customUserDetails.getUser()), any(FamilyJoinRequest.class)))
                    .willReturn(expectedFamilyInfo);

            // when
            ResponseEntity<FamilyInfo> response = familyController.joinFamily(customUserDetails, request);

            // then
            assertThat(response.getStatusCode().value()).isEqualTo(200);
            assertThat(response.getBody()).isNotNull();
            assertThat(response.getBody().code()).isEqualTo("FAM123");
            assertThat(response.getBody().name()).isEqualTo("홍길동의 가족");
            assertThat(response.getBody().memberCount()).isEqualTo(2);
        }

        @Test
        @DisplayName("실패 - 존재하지 않는 가족 코드")
        void joinFamily_InvalidFamilyCode() {
            // given
            FamilyJoinRequest request = new FamilyJoinRequest("INVALID");
            given(familyService.joinFamily(eq(customUserDetails.getUser()), any(FamilyJoinRequest.class)))
                    .willThrow(new EntityNotFoundException("존재하지 않는 가족 코드입니다."));

            // when & then
            assertThrows(EntityNotFoundException.class, () -> 
                familyController.joinFamily(customUserDetails, request)
            );
        }
    }
} 
