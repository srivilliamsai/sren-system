package com.sren.userservice.repository;

import com.sren.userservice.entity.UserEmotionRecord;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserEmotionRecordRepository extends JpaRepository<UserEmotionRecord, Long> {

    List<UserEmotionRecord> findTop10ByUserIdOrderByCapturedAtDesc(Long userId);
}
