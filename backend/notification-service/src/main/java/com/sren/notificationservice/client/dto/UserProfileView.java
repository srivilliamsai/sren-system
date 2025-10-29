package com.sren.notificationservice.client.dto;

import lombok.Data;

@Data
public class UserProfileView {
    private Long id;
    private String email;
    private String fullName;
    private String preferences;
}
