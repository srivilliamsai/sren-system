package com.sren.emotionservice.client;

import com.sren.emotionservice.client.dto.PythonEmotionRequest;
import com.sren.emotionservice.client.dto.PythonEmotionResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "pythonEmotionClient", url = "${emotion.python-api.url:http://localhost:5000}")
public interface PythonEmotionClient {

    @PostMapping("/analyze")
    PythonEmotionResponse analyze(@RequestBody PythonEmotionRequest request);
}
