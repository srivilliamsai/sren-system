package com.sren.emotionservice.client.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PythonEmotionRequest {
    private String imageUrl;
    private String imageData;
}
