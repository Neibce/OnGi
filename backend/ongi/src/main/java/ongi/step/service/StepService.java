package ongi.step.service;

import lombok.RequiredArgsConstructor;
import ongi.exception.EntityNotFoundException;
import ongi.family.entity.Family;
import ongi.family.repository.FamilyRepository;
import ongi.step.dto.FamilyStepResponse;
import ongi.step.dto.StepUpsertRequest;
import ongi.step.entity.Step;
import ongi.step.repository.StepRepository;
import ongi.user.entity.User;
import ongi.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class StepService {
    
    private final StepRepository stepRepository;
    private final FamilyRepository familyRepository;
    private final UserRepository userRepository;
    
    @Transactional
    public void upsertStep(UUID userId, StepUpsertRequest request) {
        Family family = familyRepository.findByMembersContains(userId)
                .orElseThrow(() -> new EntityNotFoundException("가족을 찾을 수 없습니다."));
        
        String familyId = family.getCode();
        LocalDate today = LocalDate.now();
        
        var existingStep = stepRepository.findByFamilyIdAndUserIdAndDate(familyId, userId, today);
        
        if (existingStep.isPresent()) {
            Step step = existingStep.get();
            step.updateSteps(request.steps());
        } else {
            Step newStep = Step.builder()
                    .familyId(familyId)
                    .userId(userId)
                    .steps(request.steps())
                    .date(today)
                    .build();
            stepRepository.save(newStep);
        }
    }
    
    public FamilyStepResponse getFamilySteps(UUID userId) {
        Family family = familyRepository.findByMembersContains(userId)
                .orElseThrow(() -> new EntityNotFoundException("가족을 찾을 수 없습니다."));
        
        String familyId = family.getCode();
        LocalDate today = LocalDate.now();
        
        List<Step> familySteps = stepRepository.findByFamilyIdAndDate(familyId, today);
        
        Integer totalSteps = stepRepository.getTotalStepsByFamilyIdAndDate(familyId, today);
        
        Map<UUID, Integer> userStepMap = familySteps.stream()
                .collect(Collectors.toMap(Step::getUserId, Step::getSteps));
        
        List<UUID> memberIds = family.getMembers();
        Map<UUID, User> memberMap = userRepository.findAllById(memberIds).stream()
                .collect(Collectors.toMap(User::getUuid, user1 -> user1));
        
        List<FamilyStepResponse.MemberStepInfo> memberSteps = memberIds.stream()
                .map(memberId -> {
                    User member = memberMap.get(memberId);
                    Integer steps = userStepMap.getOrDefault(memberId, 0);
                    
                    return new FamilyStepResponse.MemberStepInfo(
                            memberId,
                            member.getName(),
                            steps
                    );
                })
                .collect(Collectors.toList());
        
        return new FamilyStepResponse(
                totalSteps,
                today,
                memberSteps
        );
    }
} 
