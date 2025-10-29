package com.sren.recommenderservice.repository;

import com.sren.recommenderservice.entity.Recommendation;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RecommendationRepository extends JpaRepository<Recommendation, Long> {

    List<Recommendation> findTop5ByUserIdOrderByRecommendedAtDesc(Long userId);
}
