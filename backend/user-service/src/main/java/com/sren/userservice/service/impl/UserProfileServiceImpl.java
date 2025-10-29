package com.sren.userservice.service.impl;

import com.sren.userservice.client.EmotionClient;
import com.sren.userservice.client.dto.EmotionSnapshot;
import com.sren.userservice.dto.EmotionHistoryResponse;
import com.sren.userservice.dto.EmotionRecordDto;
import com.sren.userservice.dto.UpdateUserProfileRequest;
import com.sren.userservice.dto.UserProfileResponse;
import com.sren.userservice.entity.UserEmotionRecord;
import com.sren.userservice.entity.UserProfile;
import com.sren.userservice.repository.UserEmotionRecordRepository;
import com.sren.userservice.repository.UserProfileRepository;
import com.sren.userservice.service.UserProfileService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class UserProfileServiceImpl implements UserProfileService {

    private final UserProfileRepository userProfileRepository;
    private final UserEmotionRecordRepository userEmotionRecordRepository;
    private final EmotionClient emotionClient;

    @Override
    public UserProfileResponse getProfile(Long id) {
        UserProfile profile = userProfileRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User profile not found"));
        return toResponse(profile);
    }

    @Override
    public UserProfileResponse upsertProfile(UpdateUserProfileRequest request) {
        UserProfile profile = request.getId() != null
                ? userProfileRepository.findById(request.getId()).orElse(new UserProfile())
                : userProfileRepository.findByEmail(request.getEmail()).orElse(new UserProfile());

        profile.setEmail(request.getEmail());
        profile.setFullName(request.getFullName());
        profile.setPreferences(request.getPreferences());

        UserProfile saved = userProfileRepository.save(profile);
        return toResponse(saved);
    }

    @Override
    public EmotionHistoryResponse synchronizeEmotionHistory(Long userId) {
        EmotionSnapshot snapshot = emotionClient.latest(userId);
        UserEmotionRecord record = UserEmotionRecord.builder()
                .userId(userId)
                .emotion(snapshot.getDominantEmotion())
                .confidence(snapshot.getConfidence())
                .capturedAt(snapshot.getCapturedAt() == null ? Instant.now() : snapshot.getCapturedAt())
                .build();
        userEmotionRecordRepository.save(record);

        List<EmotionRecordDto> records = userEmotionRecordRepository.findTop10ByUserIdOrderByCapturedAtDesc(userId).stream()
                .map(r -> EmotionRecordDto.builder()
                        .emotion(r.getEmotion())
                        .confidence(r.getConfidence())
                        .capturedAt(r.getCapturedAt())
                        .build())
                .toList();

        return EmotionHistoryResponse.builder()
                .userId(userId)
                .records(records)
                .build();
    }

    private UserProfileResponse toResponse(UserProfile profile) {
        return UserProfileResponse.builder()
                .id(profile.getId())
                .email(profile.getEmail())
                .fullName(profile.getFullName())
                .preferences(profile.getPreferences())
                .build();
    }
}
