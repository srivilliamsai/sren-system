package com.sren.recommenderservice.controller;

import com.sren.recommenderservice.dto.RecommendationRequest;
import com.sren.recommenderservice.dto.RecommendationResponse;
import com.sren.recommenderservice.service.RecommendationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/recommendations")
@RequiredArgsConstructor
public class RecommendationController {

    private final RecommendationService recommendationService;

    @PostMapping
    public ResponseEntity<RecommendationResponse> recommend(@Valid @RequestBody RecommendationRequest request) {
        return ResponseEntity.ok(recommendationService.generateRecommendation(request));
    }

    @GetMapping("/{userId}/recent")
    public ResponseEntity<List<RecommendationResponse>> recent(@PathVariable Long userId) {
        return ResponseEntity.ok(recommendationService.recentRecommendations(userId));
    }
}
