package com.sren.userservice.controller;

import com.sren.userservice.dto.EmotionHistoryResponse;
import com.sren.userservice.dto.UpdateUserProfileRequest;
import com.sren.userservice.dto.UserProfileResponse;
import com.sren.userservice.service.UserProfileService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserProfileController {

    private final UserProfileService userProfileService;

    @GetMapping("/{id}")
    public ResponseEntity<UserProfileResponse> getProfile(@PathVariable Long id) {
        return ResponseEntity.ok(userProfileService.getProfile(id));
    }

    @PutMapping
    public ResponseEntity<UserProfileResponse> updateProfile(@Valid @RequestBody UpdateUserProfileRequest request) {
        return ResponseEntity.ok(userProfileService.upsertProfile(request));
    }

    @GetMapping("/{id}/emotions/sync")
    public ResponseEntity<EmotionHistoryResponse> syncEmotionHistory(@PathVariable Long id) {
        return ResponseEntity.ok(userProfileService.synchronizeEmotionHistory(id));
    }
}
