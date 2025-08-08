package ongi.maum_log.entity;

import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import ongi.common.entity.BaseEntity;
import ongi.maum_log.enums.Emotion;

@Entity
@Builder
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class MaumLog extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String frontFileName;

    @Column(nullable = false, unique = true)
    private String backFileName;

    private String location;

    private String comment;

    @ElementCollection(targetClass = Emotion.class)
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private List<Emotion> emotions;
}
