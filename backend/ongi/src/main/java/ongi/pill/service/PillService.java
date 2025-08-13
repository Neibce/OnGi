package ongi.pill.service;

import java.time.LocalDate;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import ongi.exception.EntityNotFoundException;
import ongi.family.entity.Family;
import ongi.family.repository.FamilyRepository;
import ongi.pill.dto.PillCreateRequest;
import ongi.pill.dto.PillInfo;
import ongi.pill.dto.PillInfoWithIntakeStatus;
import ongi.pill.dto.PillIntakeRecordRequest;
import ongi.pill.entity.Pill;
import ongi.pill.entity.PillIntakeRecord;
import ongi.pill.repository.PillIntakeRecordRepository;
import ongi.pill.repository.PillRepository;
import ongi.user.entity.User;
import ongi.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PillService {

    private final PillRepository pillRepository;
    private final UserRepository userRepository;
    private final FamilyRepository familyRepository;
    private final PillIntakeRecordRepository pillIntakeRecordRepository;

    @Transactional
    public PillInfo createPill(User child, PillCreateRequest request) {
        User parent = userRepository.findByUuid(request.parentUuid())
                .orElseThrow(() -> new EntityNotFoundException("부모 사용자를 찾을 수 없습니다."));

        if (!parent.getIsParent()) {
            throw new IllegalArgumentException("선택한 사용자는 부모가 아닙니다.");
        }

        Family family = familyRepository.findByMembersContains(child.getUuid())
                .orElseThrow(() -> new EntityNotFoundException("가족 정보를 찾을 수 없습니다."));

        if (!family.getMembers().contains(parent.getUuid())) {
            throw new IllegalArgumentException("가족에 속하지 않은 사용자입니다.");
        }

        Pill pill = Pill.builder()
                .name(request.name())
                .times(request.times())
                .intakeDetail(request.intakeDetail())
                .intakeTimes(request.intakeTimes())
                .intakeDays(request.intakeDays())
                .owner(parent)
                .build();

        Pill savedPill = pillRepository.save(pill);
        return new PillInfo(savedPill);
    }

    @Transactional
    public void recordPillIntake(User user, PillIntakeRecordRequest request) {
        if (!user.getIsParent()) {
            throw new IllegalArgumentException("해당 사용자는 부모가 아닙니다.");
        }

        Pill pill = pillRepository.findById(request.pillId())
                .orElseThrow(() -> new EntityNotFoundException("약 정보를 찾을 수 없습니다."));

        if (!pill.getIntakeTimes().contains(request.intakeTime())) {
            throw new IllegalArgumentException("해당 시간에 복용할 수 없는 약입니다.");
        }

        PillIntakeRecord pillIntakeRecord =
                pillIntakeRecordRepository.findByPillAndIntakeDateAndIntakeTime(pill,
                                request.intakeDate(), request.intakeTime())
                        .orElse(PillIntakeRecord.builder()
                                .pill(pill)
                                .intakeTime(request.intakeTime())
                                .intakeDate(request.intakeDate())
                                .build());

        pillIntakeRecordRepository.save(pillIntakeRecord);
    }

    @Transactional
    public void deletePillIntake(User user, PillIntakeRecordRequest request) {
        if (!user.getIsParent()) {
            throw new IllegalArgumentException("해당 사용자는 부모가 아닙니다.");
        }

        Pill pill = pillRepository.findById(request.pillId())
                .orElseThrow(() -> new EntityNotFoundException("약 정보를 찾을 수 없습니다."));

        PillIntakeRecord pillIntakeRecord =
                pillIntakeRecordRepository.findByPillAndIntakeDateAndIntakeTime(pill,
                                request.intakeDate(), request.intakeTime())
                        .orElseThrow(() -> new EntityNotFoundException("복용 기록을 찾을 수 없습니다."));

        pillIntakeRecordRepository.delete(pillIntakeRecord);
    }

    public List<PillInfoWithIntakeStatus> getFamilyPills(User user, UUID parentUuid,
            LocalDate date) {
        User parent = user;
        if (!user.getIsParent()) {
            if (parentUuid == null) {
                throw new IllegalArgumentException("해당 사용자는 부모가 아닙니다.");
            } else {
                parent = userRepository.findByUuid(parentUuid)
                        .orElseThrow(() -> new EntityNotFoundException("부모 사용자를 찾을 수 없습니다."));

                if (!parent.getIsParent()) {
                    throw new IllegalArgumentException("선택한 사용자는 부모가 아닙니다.");
                }
            }
        }

        List<Pill> pills = pillRepository.findByOwner(parent);
        List<PillIntakeRecord> allRecords = pillIntakeRecordRepository.findByPillInAndIntakeDate(
                pills, date);

        Map<Long, List<PillIntakeRecord>> intakeRecordsMap = allRecords.stream()
                .collect(Collectors.groupingBy(record -> record.getPill().getId()));

        return pills.stream()
                .map(pill -> new PillInfoWithIntakeStatus(pill,
                        intakeRecordsMap.getOrDefault(pill.getId(), List.of())))
                .toList();
    }
}
