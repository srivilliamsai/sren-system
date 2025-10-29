package com.sren.userservice.client;

import com.sren.userservice.client.dto.EmotionSnapshot;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "emotion-service")
public interface EmotionClient {

    @GetMapping("/api/v1/emotions/{userId}/latest")
    EmotionSnapshot latest(@PathVariable("userId") Long userId);
}
