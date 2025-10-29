package com.sren.notificationservice.service;

import com.sren.notificationservice.dto.NotificationResponse;
import com.sren.notificationservice.dto.SendNotificationRequest;

public interface NotificationService {

    NotificationResponse sendNotification(SendNotificationRequest request);
}
