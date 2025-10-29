package com.sren.authservice.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RegisterRequest {

    @Email
    @NotBlank
    private String email;

    @NotBlank
    private String fullName;

    @Size(min = 6, message = "Password must be at least 6 characters long")
    private String password;
}
