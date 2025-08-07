package ongi.step.service;

import java.time.temporal.TemporalAdjusters;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import ongi.exception.EntityNotFoundException;
import ongi.family.entity.Family;
import ongi.family.repository.FamilyRepository;
import ongi.step.dto.FamilyStepRankingResponse;
import ongi.step.dto.FamilyStepResponse;
import ongi.step.dto.FamilyStepResponse.MemberStepInfo;
import ongi.step.dto.StepUpsertRequest;
import ongi.step.entity.Step;
import ongi.step.repository.StepRepository;
import ongi.user.entity.User;
import ongi.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class StepService {

    private final StepRepository stepRepository;
    private final FamilyRepository familyRepository;
    private final UserRepository userRepository;

    @Transactional
    public void upsertStep(User user, StepUpsertRequest request) {
        Family family = familyRepository.findByMembersContains(user.getUuid())
                .orElseThrow(() -> new EntityNotFoundException("가족을 찾을 수 없습니다."));

        LocalDate today = LocalDate.now();
        Optional<Step> existingStep = stepRepository.findByCreatedByAndDate(user, today);

        if (existingStep.isPresent()) {
            Step step = existingStep.get();
            step.updateSteps(request.steps());
        } else {
            Step newStep = Step.builder()
                    .family(family)
                    .steps(request.steps())
                    .date(today)
                    .build();
            stepRepository.save(newStep);
        }
    }

    public FamilyStepResponse getFamilySteps(User user, LocalDate date) {
        Family family = familyRepository.findByMembersContains(user.getUuid())
                .orElseThrow(() -> new EntityNotFoundException("가족을 찾을 수 없습니다."));

        List<Step> familySteps = stepRepository.findByFamilyAndDate(family, date);
        Integer totalSteps = stepRepository.getTotalStepsByFamilyAndDate(family, date);


        List<MemberStepInfo> memberSteps = family.getMembers().stream().map(uuid ->
                new MemberStepInfo(uuid, userRepository.findByUuid(uuid).get().getName(),
                familySteps.stream()
                        .filter(step -> step.getCreatedBy().getUuid().equals(uuid))
                        .findFirst()
                        .map(Step::getSteps)
                        .orElse(0))).toList();

        return new FamilyStepResponse(
                totalSteps,
                date,
                memberSteps
        );
    }


    /// TODO ///
    public List<FamilyStepRankingResponse> getFamilyStepRanking(User user, LocalDate date) {
        Family family = familyRepository.findByMembersContains(user.getUuid())
                .orElseThrow(() -> new EntityNotFoundException("가족을 찾을 수 없습니다."));

        // TODO
        return null;
    }

    private int get7DaysAverageSteps(Family family) {
        LocalDate today = LocalDate.now();
        List<Step> familySteps = stepRepository.findByFamilyAndDateBetween(family, today,
                getThisWeekMonday(today));

        int totalSteps = familySteps.stream()
                .mapToInt(Step::getSteps)
                .sum();

        return totalSteps / family.getMembers().size();
    }

    public LocalDate getThisWeekMonday(LocalDate date) {
        return date.with(TemporalAdjusters.previousOrSame(java.time.DayOfWeek.MONDAY));
    }
} 
