package com.sren.authservice.service.impl;

import com.sren.authservice.entity.UserAccount;
import com.sren.authservice.repository.UserAccountRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserAccountDetailsService implements UserDetailsService {

    private final UserAccountRepository userAccountRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        UserAccount account = userAccountRepository.findByEmail(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
        return toUserDetails(account);
    }

    public UserDetails toUserDetails(UserAccount account) {
        return new User(
                account.getEmail(),
                account.getPassword(),
                List.of(new SimpleGrantedAuthority("ROLE_" + account.getRole().name()))
        );
    }
}

