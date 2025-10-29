package com.sren.emotionservice.client.dto;

import lombok.Data;

@Data
public class PythonEmotionResponse {
    private String emotion;
    private double confidence;
}
