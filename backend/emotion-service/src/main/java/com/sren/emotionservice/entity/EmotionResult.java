package com.sren.emotionservice.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "emotion_results")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmotionResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private String dominantEmotion;

    @Column(nullable = false)
    private double confidence;

    @Column(nullable = false)
    private Instant capturedAt;

    @Column
    private String source;
}
