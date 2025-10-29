package com.sren.userservice.client.dto;

import java.time.Instant;
import lombok.Data;

@Data
public class EmotionSnapshot {
    private Long userId;
    private String dominantEmotion;
    private double confidence;
    private Instant capturedAt;
}
