package ongi.family.service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import ongi.exception.EntityAlreadyExistException;
import ongi.exception.EntityNotFoundException;
import ongi.family.dto.FamilyCreateRequest;
import ongi.family.dto.FamilyInfo;
import ongi.family.dto.FamilyJoinRequest;
import ongi.family.entity.Family;
import ongi.family.repository.FamilyRepository;
import ongi.family.support.FamilyCodeGenerator;
import ongi.user.dto.UserInfo;
import ongi.user.entity.User;
import ongi.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FamilyService {

    private final FamilyRepository familyRepository;
    private final UserRepository userRepository;
    private final FamilyCodeGenerator familyCodeGenerator;

    public FamilyInfo getFamily(User user) {
        Family family = familyRepository.findByMembersContains(user.getUuid())
                .orElseThrow(() -> new EntityNotFoundException("가족 정보를 찾을 수 없습니다."));
        return new FamilyInfo(family);
    }

    @Transactional
    public FamilyInfo createFamily(User user, FamilyCreateRequest request) {
        if (familyRepository.existsByMembersContains(user.getUuid())) {
            throw new EntityAlreadyExistException("이미 소속된 가족이 있습니다.");
        }

        for (int i = 0; i < FamilyCodeGenerator.MAX_RETRY; i++) {
            String code = familyCodeGenerator.generate();
            if (familyRepository.existsByCode(code)) {
                continue;
            }

            List<UUID> members = new ArrayList<>();
            members.add(user.getUuid());

            Family newFamily = familyRepository.save(Family.builder()
                    .code(code)
                    .name(request.name())
                    .members(members)
                    .build());

            return new FamilyInfo(newFamily);
        }
        throw new IllegalStateException("초대 코드를 생성할 수 없습니다.");
    }

    @Transactional
    public FamilyInfo joinFamily(User user, FamilyJoinRequest request) {
        if (familyRepository.existsByMembersContains(user.getUuid())) {
            throw new EntityAlreadyExistException("이미 소속된 가족이 있습니다.");
        }

        Family family = familyRepository.findByCode(request.code())
                .orElseThrow(() -> new EntityNotFoundException("해당 가족을 찾을 수 없습니다."));

        family.getMembers().add(user.getUuid());
        return new FamilyInfo(family);
    }

    public List<UserInfo> getFamilyMembers(User user) {
        Family family = familyRepository.findByMembersContains(user.getUuid())
                .orElseThrow(() -> new EntityNotFoundException("가족 정보를 찾을 수 없습니다."));

        return family.getMembers().stream()
                .map(memberId -> new UserInfo(userRepository.findByUuid(memberId)
                        .orElseThrow(() -> new EntityNotFoundException("가족 멤버 중 탈퇴한 사용자가 있습니다."))))
                .toList();
    }
}
