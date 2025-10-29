package com.sren.recommenderservice.client;

import com.sren.recommenderservice.client.dto.EmotionSnapshot;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "emotion-service")
public interface EmotionClient {

    @GetMapping("/api/v1/emotions/{userId}/latest")
    EmotionSnapshot fetchLatest(@PathVariable("userId") Long userId);
}
