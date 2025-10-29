package com.sren.notificationservice.controller;

import com.sren.notificationservice.dto.NotificationResponse;
import com.sren.notificationservice.dto.SendNotificationRequest;
import com.sren.notificationservice.service.NotificationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @PostMapping
    public ResponseEntity<NotificationResponse> send(@Valid @RequestBody SendNotificationRequest request) {
        return ResponseEntity.ok(notificationService.sendNotification(request));
    }
}
