package ongi.step.entity;

import jakarta.persistence.*;
import lombok.*;
import ongi.common.entity.BaseEntity;
import ongi.family.entity.Family;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDate;

@Entity
@Table(uniqueConstraints = {
    @UniqueConstraint(columnNames = {"family_code", "created_by_uuid", "date"})
})
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Getter
@EntityListeners(AuditingEntityListener.class)
public class Step extends BaseEntity {
    
    @Id
    @GeneratedValue
    @Column(nullable = false, updatable = false)
    private Long id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    private Family family;
    
    @Column(nullable = false)
    private Integer steps;
    
    @Column(nullable = false)
    private LocalDate date;

    public void updateSteps(Integer newSteps) {
        this.steps = newSteps;
    }
} 
