package com.sren.userservice.service;

import com.sren.userservice.dto.EmotionHistoryResponse;
import com.sren.userservice.dto.UpdateUserProfileRequest;
import com.sren.userservice.dto.UserProfileResponse;

public interface UserProfileService {

    UserProfileResponse getProfile(Long id);

    UserProfileResponse upsertProfile(UpdateUserProfileRequest request);

    EmotionHistoryResponse synchronizeEmotionHistory(Long userId);
}
