package com.sren.notificationservice.dto;

import java.time.Instant;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class NotificationResponse {
    private Long userId;
    private String channel;
    private String message;
    private String status;
    private Instant sentAt;
}
