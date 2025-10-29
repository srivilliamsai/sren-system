package com.sren.emotionservice.service;

import com.sren.emotionservice.dto.EmotionAnalysisRequest;
import com.sren.emotionservice.dto.EmotionAnalysisResponse;

public interface EmotionService {

    EmotionAnalysisResponse analyzeEmotion(EmotionAnalysisRequest request);

    EmotionAnalysisResponse findLatestByUserId(Long userId);
}
