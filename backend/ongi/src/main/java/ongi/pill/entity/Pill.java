package ongi.pill.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import java.time.DayOfWeek;
import java.time.LocalTime;
import java.util.List;
import java.util.Set;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import ongi.common.entity.BaseEntity;
import ongi.user.entity.User;

@Entity
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Getter
public class Pill extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private Integer times;

    @Column(nullable = false)
    private IntakeDetail intakeDetail;

    @Column(nullable = false)
    private List<LocalTime> intakeTimes;

    @Column(nullable = false)
    private Set<DayOfWeek> intakeDays;

    @ManyToOne(fetch = FetchType.LAZY)
    private User owner;
}
