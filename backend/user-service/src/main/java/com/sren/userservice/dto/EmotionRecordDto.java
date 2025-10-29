package com.sren.userservice.dto;

import java.time.Instant;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class EmotionRecordDto {
    private String emotion;
    private double confidence;
    private Instant capturedAt;
}
