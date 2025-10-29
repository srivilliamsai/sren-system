package com.sren.authservice.service.impl;

import com.sren.authservice.dto.AuthResponse;
import com.sren.authservice.dto.LoginRequest;
import com.sren.authservice.dto.RegisterRequest;
import com.sren.authservice.entity.UserAccount;
import com.sren.authservice.entity.UserRole;
import com.sren.authservice.repository.UserAccountRepository;
import com.sren.authservice.security.JwtTokenProvider;
import com.sren.authservice.service.AuthService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Transactional
public class AuthServiceImpl implements AuthService {

    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final UserAccountDetailsService userAccountDetailsService;

    @Override
    public AuthResponse register(RegisterRequest request) {
        if (userAccountRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email already registered");
        }

        UserAccount account = UserAccount.builder()
                .email(request.getEmail())
                .fullName(request.getFullName())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(UserRole.USER)
                .build();

        userAccountRepository.save(account);
        UserDetails userDetails = userAccountDetailsService.toUserDetails(account);
        String token = jwtTokenProvider.generateToken(userDetails);

        return AuthResponse.builder()
                .token(token)
                .email(account.getEmail())
                .fullName(account.getFullName())
                .build();
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(
                request.getEmail(),
                request.getPassword()
        );
        authenticationManager.authenticate(authenticationToken);

        UserAccount account = userAccountRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UsernameNotFoundException("Invalid credentials"));

        UserDetails userDetails = userAccountDetailsService.toUserDetails(account);
        String token = jwtTokenProvider.generateToken(userDetails);

        return AuthResponse.builder()
                .token(token)
                .email(account.getEmail())
                .fullName(account.getFullName())
                .build();
    }
}
