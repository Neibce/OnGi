package ongi.util;

import io.awspring.cloud.s3.ObjectMetadata;
import io.awspring.cloud.s3.S3Template;
import java.net.URL;
import java.time.Duration;
import lombok.AllArgsConstructor;
import ongi.user.entity.User;
import org.springframework.stereotype.Component;

@Component
@AllArgsConstructor
public class S3FileService {

    private final S3Template s3Template;

    public URL createSignedPutUrl(User uploader, String dir, String filename) {
        ObjectMetadata metadata = ObjectMetadata.builder()
                .metadata("uploader", uploader.getUuid().toString())
                .build();

        return s3Template.createSignedPutURL("ongi2025-bucket", dir + "/" + filename,
                Duration.ofMinutes(3), metadata, null);
    }

    public URL createSignedGetUrl(String dir, String filename) {
        return s3Template.createSignedGetURL("ongi2025-bucket", dir + "/" + filename,
                Duration.ofMinutes(3));
    }

    public boolean objectExists(String dir, String filename) {
        return s3Template.objectExists("ongi2025-bucket", dir + "/" + filename);
    }
}
