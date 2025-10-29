package com.sren.recommenderservice.service.impl;

import com.sren.recommenderservice.client.EmotionClient;
import com.sren.recommenderservice.client.dto.EmotionSnapshot;
import com.sren.recommenderservice.dto.RecommendationRequest;
import com.sren.recommenderservice.dto.RecommendationResponse;
import com.sren.recommenderservice.entity.Recommendation;
import com.sren.recommenderservice.repository.RecommendationRepository;
import com.sren.recommenderservice.service.RecommendationService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional
public class RecommendationServiceImpl implements RecommendationService {

    private static final Map<String, String> CONTENT_LIBRARY = Map.of(
            "HAPPY", "Uplifting Playlist",
            "SAD", "Comforting Podcast",
            "ANGRY", "Guided Meditation",
            "SURPRISED", "Trending Documentary",
            "NEUTRAL", "Curated News Digest"
    );

    private final EmotionClient emotionClient;
    private final RecommendationRepository recommendationRepository;

    @Override
    public RecommendationResponse generateRecommendation(RecommendationRequest request) {
        EmotionSnapshot snapshot = emotionClient.fetchLatest(request.getUserId());
        String emotion = snapshot.getDominantEmotion().toUpperCase();
        String contentTitle = CONTENT_LIBRARY.getOrDefault(emotion, "Personal Growth Article");
        String contentType = determineContentType(contentTitle);

        Recommendation recommendation = Recommendation.builder()
                .userId(request.getUserId())
                .emotion(emotion)
                .contentTitle(contentTitle)
                .contentType(contentType)
                .rationale("Based on latest recognized emotion")
                .recommendedAt(Instant.now())
                .build();

        Recommendation saved = recommendationRepository.save(recommendation);
        return toResponse(saved);
    }

    @Override
    public List<RecommendationResponse> recentRecommendations(Long userId) {
        return recommendationRepository.findTop5ByUserIdOrderByRecommendedAtDesc(userId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private RecommendationResponse toResponse(Recommendation recommendation) {
        return RecommendationResponse.builder()
                .userId(recommendation.getUserId())
                .emotion(recommendation.getEmotion())
                .contentTitle(recommendation.getContentTitle())
                .contentType(recommendation.getContentType())
                .rationale(recommendation.getRationale())
                .recommendedAt(recommendation.getRecommendedAt())
                .build();
    }

    private String determineContentType(String title) {
        if (title.toLowerCase().contains("playlist")) {
            return "AUDIO";
        }
        if (title.toLowerCase().contains("podcast")) {
            return "PODCAST";
        }
        if (title.toLowerCase().contains("meditation")) {
            return "WELLNESS";
        }
        if (title.toLowerCase().contains("documentary")) {
            return "VIDEO";
        }
        return "ARTICLE";
    }
}
