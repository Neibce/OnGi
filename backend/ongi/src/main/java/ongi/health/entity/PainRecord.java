package ongi.health.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PainRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private UUID parentId;

    @Column(nullable = false)
    private LocalDate date;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PainArea painArea;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PainLevel painLevel;

    public enum PainArea {
        HEAD, NECK, SHOULDER, CHEST, BACK, ARM, HAND, ABDOMEN, WAIST, LEG, KNEE, FOOT, NONE
    }

    public enum PainLevel {
        STRONG, MID_STRONG, MID_WEAK, WEAK
    }
} 