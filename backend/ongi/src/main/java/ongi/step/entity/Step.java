package ongi.step.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(uniqueConstraints = {
    @UniqueConstraint(columnNames = {"family_id", "user_id", "date"})
})
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Getter
@EntityListeners(AuditingEntityListener.class)
public class Step {
    
    @Id
    @GeneratedValue
    @Column(nullable = false, updatable = false)
    private Long id;
    
    @Column(nullable = false)
    private String familyId;
    
    @Column(nullable = false)
    private UUID userId;
    
    @Column(nullable = false)
    private Integer steps;
    
    @Column(nullable = false)
    private LocalDate date;
    
    @CreatedDate
    @Column(updatable = false, nullable = false)
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    public void updateSteps(Integer newSteps) {
        this.steps = newSteps;
    }
} 
