package com.sren.userservice.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UpdateUserProfileRequest {

    private Long id;

    @Email
    @NotBlank
    private String email;

    @NotBlank
    private String fullName;

    private String preferences;
}
