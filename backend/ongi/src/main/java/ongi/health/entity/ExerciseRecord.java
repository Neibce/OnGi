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
public class ExerciseRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private UUID parentId;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false, length = 144)
    private String grid; // 10분 단위 운동 구간, 144칸(24시간*6)

    @Column(nullable = false, length = 5)
    private String duration; // 시:분 포맷("00:00")

    public void setGrid(String grid) {
        this.grid = grid;
        this.duration = calculateDurationFromGrid(grid);
    }
    private String calculateDurationFromGrid(String grid) {
        if (grid == null) return "00:00";
        int count = (int) grid.chars().filter(c -> c == '1').count();
        int totalMin = count * 10;
        int hour = totalMin / 60;
        int min = totalMin % 60;
        return String.format("%02d:%02d", hour, min);
    }
    
} 