package com.sren.notificationservice.service.impl;

import com.sren.notificationservice.client.UserClient;
import com.sren.notificationservice.client.dto.UserProfileView;
import com.sren.notificationservice.dto.NotificationResponse;
import com.sren.notificationservice.dto.SendNotificationRequest;
import com.sren.notificationservice.entity.NotificationLog;
import com.sren.notificationservice.repository.NotificationLogRepository;
import com.sren.notificationservice.service.NotificationService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class NotificationServiceImpl implements NotificationService {

    private final NotificationLogRepository notificationLogRepository;
    private final UserClient userClient;

    @Override
    public NotificationResponse sendNotification(SendNotificationRequest request) {
        UserProfileView user = userClient.getUser(request.getUserId());

        String status = dispatch(request.getChannel(), user.getEmail(), request.getMessage());
        NotificationLog logEntry = NotificationLog.builder()
                .userId(request.getUserId())
                .channel(request.getChannel())
                .message(request.getMessage())
                .status(status)
                .sentAt(Instant.now())
                .build();
        notificationLogRepository.save(logEntry);

        return NotificationResponse.builder()
                .userId(request.getUserId())
                .channel(request.getChannel())
                .message(request.getMessage())
                .status(status)
                .sentAt(logEntry.getSentAt())
                .build();
    }

    private String dispatch(String channel, String destination, String message) {
        // In production integrate with actual providers.
        log.info("Dispatching {} notification to {} with message {}", channel, destination, message);
        return "DELIVERED";
    }
}
