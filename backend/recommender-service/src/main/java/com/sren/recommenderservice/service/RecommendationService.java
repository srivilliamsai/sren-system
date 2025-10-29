package com.sren.recommenderservice.service;

import com.sren.recommenderservice.dto.RecommendationRequest;
import com.sren.recommenderservice.dto.RecommendationResponse;
import java.util.List;

public interface RecommendationService {

    RecommendationResponse generateRecommendation(RecommendationRequest request);

    List<RecommendationResponse> recentRecommendations(Long userId);
}
