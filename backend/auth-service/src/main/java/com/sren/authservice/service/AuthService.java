package com.sren.authservice.service;

import com.sren.authservice.dto.AuthResponse;
import com.sren.authservice.dto.LoginRequest;
import com.sren.authservice.dto.RegisterRequest;

public interface AuthService {

    AuthResponse register(RegisterRequest request);

    AuthResponse login(LoginRequest request);
}
