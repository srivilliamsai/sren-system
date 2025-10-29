package com.sren.emotionservice.repository;

import com.sren.emotionservice.entity.EmotionResult;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmotionResultRepository extends JpaRepository<EmotionResult, Long> {

    Optional<EmotionResult> findFirstByUserIdOrderByCapturedAtDesc(Long userId);
}
