package ongi.firebase;

import com.google.firebase.FirebaseApp;
import jakarta.annotation.PostConstruct;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FirebaseConfig {

    @PostConstruct
    public void initFirebase() {
        FirebaseApp.initializeApp();
    }
}
