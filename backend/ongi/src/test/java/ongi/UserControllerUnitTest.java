package ongi;

import ongi.exception.GlobalExceptionHandler;
import ongi.security.CustomUserDetails;
import ongi.user.controller.UserController;
import ongi.user.dto.UserInfo;
import ongi.user.entity.User;
import ongi.user.service.UserService;
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

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@ExtendWith(MockitoExtension.class)
class UserControllerUnitTest {

    @Mock
    private UserService userService;

    @InjectMocks
    private UserController userController;

    private MockMvc mockMvc;
    private CustomUserDetails customUserDetails;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(userController)
                .setControllerAdvice(new GlobalExceptionHandler())
                .build();

        User testUser = User.builder()
                .uuid(UUID.randomUUID())
                .email("test@example.com")
                .password("encodedPassword")
                .name("홍길동")
                .isParent(true)
                .build();
        customUserDetails = new CustomUserDetails(testUser);
    }

    @Test
    @DisplayName("GET /users/me - 현재 사용자 정보 조회 성공")
    void getCurrentUser_Success() throws Exception {
        // when
        UserInfo result = userController.getCurrentUser(customUserDetails).getBody();

        // then
        assertNotNull(result);
        assertEquals(customUserDetails.getUser().getUuid(), result.uuid());
        assertEquals("test@example.com", result.email());
        assertEquals("홍길동", result.name());
        assertEquals(true, result.isParent());
    }

    @Test
    @DisplayName("GET /users/exists?email=test@example.com - 사용자 존재함")
    void getUserExists_UserExists() throws Exception {
        // given
        String email = "test@example.com";
        given(userService.getUserExists(email)).willReturn(true);

        // when & then
        mockMvc.perform(get("/users/exists")
                        .param("email", email))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.exists").value(true));
    }

    @Test
    @DisplayName("GET /users/exists?email=notfound@example.com - 사용자 존재하지 않음")
    void getUserExists_UserNotExists() throws Exception {
        // given
        String email = "notfound@example.com";
        given(userService.getUserExists(email)).willReturn(false);

        // when & then
        mockMvc.perform(get("/users/exists")
                        .param("email", email))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.exists").value(false));
    }

    @Test
    @DisplayName("GET /users/exists - 이메일 파라미터 없음")
    void getUserExists_NoEmailParameter() throws Exception {
        // given
        given(userService.getUserExists(null)).willReturn(false);

        // when & then
        mockMvc.perform(get("/users/exists"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.exists").value(false));
    }
}
