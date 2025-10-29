package com.sren.notificationservice.exception;

import java.time.Instant;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ApiError {
    private Instant timestamp;
    private int status;
    private String error;
    private String message;
    private String path;
}
