package ongi.family.support;

import java.security.SecureRandom;
import org.springframework.stereotype.Component;

@Component
public class FamilyCodeGenerator {

    private static final int CODE_LENGTH = 6;
    public static final int MAX_RETRY = 10;
    private static final String CHARS = "ABCDEFGHJKMNPQRSTUVWXYZ123456789";

    public String generate() {
        SecureRandom secureRandom = new SecureRandom();
        StringBuilder stringBuilder = new StringBuilder(CODE_LENGTH);
        for (int i = 0; i < CODE_LENGTH; i++) {
            stringBuilder.append(CHARS.charAt(secureRandom.nextInt(CHARS.length())));
        }
        return stringBuilder.toString();
    }
}
