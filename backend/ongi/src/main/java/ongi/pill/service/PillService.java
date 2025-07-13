package ongi.pill.service;

import lombok.RequiredArgsConstructor;
import ongi.exception.EntityNotFoundException;
import ongi.family.entity.Family;
import ongi.family.repository.FamilyRepository;
import ongi.pill.dto.PillCreateRequest;
import ongi.pill.dto.PillInfo;
import ongi.pill.entity.Pill;
import ongi.pill.repository.PillRepository;
import ongi.user.entity.User;
import ongi.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PillService {

    private final PillRepository pillRepository;
    private final UserRepository userRepository;
    private final FamilyRepository familyRepository;

    @Transactional
    public PillInfo createPill(User child, PillCreateRequest request) {
        if (child.getIsParent()) {
            throw new IllegalArgumentException("부모는 약을 등록할 수 없습니다.");
        }

        User parent = userRepository.findByUuid(request.parentUuid())
                .orElseThrow(() -> new EntityNotFoundException("부모 사용자를 찾을 수 없습니다."));

        if (!parent.getIsParent()) {
            throw new IllegalArgumentException("선택한 사용자는 부모가 아닙니다.");
        }

        Family family = familyRepository.findByMembersContains(child.getUuid())
                .orElseThrow(() -> new EntityNotFoundException("가족 정보를 찾을 수 없습니다."));

        if (!family.getMembers().contains(parent.getUuid())) {
            throw new IllegalArgumentException("같은 가족의 부모만 약을 등록할 수 있습니다.");
        }

        Pill pill = Pill.builder()
                .name(request.name())
                .intakeDetail(request.intakeDetail())
                .intakeTime(request.intakeTime())
                .owner(parent.getUuid())
                .build();

        Pill savedPill = pillRepository.save(pill);
        return new PillInfo(savedPill);
    }

    public List<PillInfo> getFamilyPills(User user) {
        Family family = familyRepository.findByMembersContains(user.getUuid())
                .orElseThrow(() -> new EntityNotFoundException("가족 정보를 찾을 수 없습니다."));

        List<Pill> pills = pillRepository.findByOwnerIn(family.getMembers());
        return pills.stream()
                .map(PillInfo::new)
                .toList();
    }

    public List<PillInfo> getMyPills(User user) {
        List<Pill> pills = pillRepository.findByOwner(user.getUuid());
        return pills.stream()
                .map(PillInfo::new)
                .toList();
    }
}
