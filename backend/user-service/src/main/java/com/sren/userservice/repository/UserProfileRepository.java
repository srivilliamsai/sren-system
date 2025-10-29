package com.sren.userservice.repository;

import com.sren.userservice.entity.UserProfile;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserProfileRepository extends JpaRepository<UserProfile, Long> {

    Optional<UserProfile> findByEmail(String email);
}
