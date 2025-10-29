package com.sren.emotionservice.service.impl;

import com.sren.emotionservice.client.PythonEmotionClient;
import com.sren.emotionservice.client.dto.PythonEmotionRequest;
import com.sren.emotionservice.client.dto.PythonEmotionResponse;
import com.sren.emotionservice.dto.EmotionAnalysisRequest;
import com.sren.emotionservice.dto.EmotionAnalysisResponse;
import com.sren.emotionservice.entity.EmotionResult;
import com.sren.emotionservice.repository.EmotionResultRepository;
import com.sren.emotionservice.service.EmotionService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
@RequiredArgsConstructor
@Transactional
public class EmotionServiceImpl implements EmotionService {

    private final PythonEmotionClient pythonEmotionClient;
    private final EmotionResultRepository emotionResultRepository;

    @Override
    public EmotionAnalysisResponse analyzeEmotion(EmotionAnalysisRequest request) {
        PythonEmotionRequest pythonRequest = PythonEmotionRequest.builder()
                .imageUrl(request.getImageUrl())
                .imageData(request.getImageData())
                .build();
        PythonEmotionResponse pythonResponse = pythonEmotionClient.analyze(pythonRequest);
        if (pythonResponse == null) {
            throw new IllegalStateException("Emotion provider returned empty response");
        }
        double confidence = pythonResponse.getConfidence() > 0 ? pythonResponse.getConfidence() : 0.5;

        EmotionResult result = EmotionResult.builder()
                .userId(request.getUserId())
                .dominantEmotion(pythonResponse.getEmotion())
                .confidence(confidence)
                .capturedAt(Instant.now())
                .source(request.getSource())
                .build();
        emotionResultRepository.save(result);
        return toResponse(result);
    }

    @Override
    public EmotionAnalysisResponse findLatestByUserId(Long userId) {
        EmotionResult latest = emotionResultRepository.findFirstByUserIdOrderByCapturedAtDesc(userId)
                .orElseThrow(() -> new IllegalArgumentException("No emotion history for user"));
        return toResponse(latest);
    }

    private EmotionAnalysisResponse toResponse(EmotionResult result) {
        return EmotionAnalysisResponse.builder()
                .userId(result.getUserId())
                .dominantEmotion(result.getDominantEmotion())
                .confidence(result.getConfidence())
                .capturedAt(result.getCapturedAt())
                .build();
    }
}
