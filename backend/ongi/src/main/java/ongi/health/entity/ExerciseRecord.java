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

    @Column(columnDefinition = "json", nullable = false)
    @Convert(converter = Int2DArrayToJsonConverter.class)
    private int[][] grid;

    @Column(nullable = false, length = 5)
    private String duration; // 시:분 포맷("00:00")

    public void setGrid(int[][] grid) {
        this.grid = grid;
        this.duration = calculateDurationFromGrid(grid);
    }
    private String calculateDurationFromGrid(int[][] grid) {
        if (grid == null) return "00:00";
        int count = 0;
        for (int i = 0; i < 24; i++)
            for (int j = 0; j < 6; j++)
                if (grid[i][j] == 1) count++;
        int totalMin = count * 10;
        int hour = totalMin / 60;
        int min = totalMin % 60;
        return String.format("%02d:%02d", hour, min);
    }
    
} 