package ongi.maum_log.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.NoArgsConstructor;
import ongi.common.entity.BaseEntity;
import ongi.maum_log.enums.Emotion;

@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MaumLog extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String fileName;

    @Column(nullable = false)
    private String fileExtension;

    private String location;

    private String comment;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private List<Emotion> emotions;
}
