package com.sren.emotionservice.dto;

import java.time.Instant;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class EmotionAnalysisResponse {

    private Long userId;
    private String dominantEmotion;
    private double confidence;
    private Instant capturedAt;
}
