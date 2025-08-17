package ongi.health.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.util.UUID;
import java.util.List;

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

    @Column(columnDefinition = "json", nullable = false)
    @Convert(converter = PainAreaListToJsonConverter.class)
    private List<PainArea> painArea;


    public enum PainArea {
        // 머리
        HEAD,
        // 목
        NECK,
        // 어깨 (좌우 구분)
        LEFT_SHOULDER, RIGHT_SHOULDER,
        // 가슴
        CHEST,
        // 등
        BACK,
        // 팔 (좌우 구분, 윗팔/아랫팔 구분)
        LEFT_UPPER_ARM, RIGHT_UPPER_ARM,
        LEFT_FOREARM, RIGHT_FOREARM,
        // 손 (좌우 구분)
        LEFT_HAND, RIGHT_HAND,
        // 배
        ABDOMEN,
        // 허리
        WAIST,
        // 골반 (좌우 구분)
        PELVIS,
        // 엉덩이 (좌우 구분)
        HIP,
        // 다리 (좌우 구분, 허벅지/종아리 구분)
        LEFT_THIGH, RIGHT_THIGH,
        LEFT_CALF, RIGHT_CALF,
        // 무릎 (좌우 구분)
        LEFT_KNEE, RIGHT_KNEE,
        // 발 (좌우 구분)
        LEFT_FOOT, RIGHT_FOOT,
        // 없음
        NONE
    }

} 