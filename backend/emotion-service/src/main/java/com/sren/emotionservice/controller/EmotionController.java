package com.sren.emotionservice.controller;

import com.sren.emotionservice.dto.EmotionAnalysisRequest;
import com.sren.emotionservice.dto.EmotionAnalysisResponse;
import com.sren.emotionservice.service.EmotionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/emotions")
@RequiredArgsConstructor
public class EmotionController {

    private final EmotionService emotionService;

    @PostMapping("/analyze")
    public ResponseEntity<EmotionAnalysisResponse> analyze(@Valid @RequestBody EmotionAnalysisRequest request) {
        return ResponseEntity.ok(emotionService.analyzeEmotion(request));
    }

    @GetMapping("/{userId}/latest")
    public ResponseEntity<EmotionAnalysisResponse> latest(@PathVariable Long userId) {
        return ResponseEntity.ok(emotionService.findLatestByUserId(userId));
    }
}
