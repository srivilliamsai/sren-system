package com.sren.emotionservice.dto;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.util.StringUtils;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EmotionAnalysisRequest {

    @Min(1)
    private Long userId;

    private String imageUrl;
    private String imageData;
    private String source;

    @AssertTrue(message = "Either imageUrl or imageData must be provided")
    public boolean hasValidPayload() {
        return StringUtils.hasText(imageUrl) || StringUtils.hasText(imageData);
    }
}
