package com.sren.notificationservice.client;

import com.sren.notificationservice.client.dto.UserProfileView;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "user-service")
public interface UserClient {

    @GetMapping("/api/v1/users/{id}")
    UserProfileView getUser(@PathVariable("id") Long id);
}
