package com.sren.notificationservice.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SendNotificationRequest {

    @Min(1)
    private Long userId;

    @NotBlank
    private String channel;

    @NotBlank
    private String message;
}
