package com.sren.userservice.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserProfileResponse {

    private Long id;
    private String email;
    private String fullName;
    private String preferences;
}
