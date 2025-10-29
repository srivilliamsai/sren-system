package com.sren.recommenderservice.dto;

import java.time.Instant;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RecommendationResponse {

    private Long userId;
    private String emotion;
    private String contentTitle;
    private String contentType;
    private String rationale;
    private Instant recommendedAt;
}
