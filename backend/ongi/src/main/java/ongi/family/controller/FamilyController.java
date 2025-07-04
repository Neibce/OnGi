package ongi.family.controller;

import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import lombok.RequiredArgsConstructor;
import ongi.family.dto.FamilyCreateRequest;
import ongi.family.dto.FamilyInfo;
import ongi.family.dto.FamilyJoinRequest;
import ongi.family.service.FamilyService;
import ongi.security.CustomUserDetails;
import ongi.user.dto.UserInfo;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RequestMapping("/family")
@RestController
@RequiredArgsConstructor
public class FamilyController {

    private final FamilyService familyService;

    @GetMapping
    public ResponseEntity<FamilyInfo> getFamilyInfo(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        FamilyInfo createdFamilyinfo = familyService.getFamily(userDetails.getUser());
        return ResponseEntity.ok(createdFamilyinfo);
    }

    @GetMapping("/members")
    public ResponseEntity<List<UserInfo>> getFamilyMembers(
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        List<UserInfo> familyMembers = familyService.getFamilyMembers(userDetails.getUser());
        return ResponseEntity.ok(familyMembers);
    }

    @PostMapping
    public ResponseEntity<FamilyInfo> createFamily(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody FamilyCreateRequest request) {
        FamilyInfo createdFamilyinfo = familyService.createFamily(userDetails.getUser(), request);
        return ResponseEntity.created(URI.create("/")).body(createdFamilyinfo);
    }

    @PostMapping("/join")
    public ResponseEntity<FamilyInfo> joinFamily(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody FamilyJoinRequest request) {
        FamilyInfo familyInfo = familyService.joinFamily(userDetails.getUser(), request);
        return ResponseEntity.ok(familyInfo);
    }
}
