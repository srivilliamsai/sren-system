package com.sren.apigateway.config;

import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GatewayRoutesConfig {

    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                .route("auth-service", r -> r.path("/api/v1/auth/**")
                        .uri("lb://auth-service"))
                .route("emotion-service", r -> r.path("/api/v1/emotions/**")
                        .uri("lb://emotion-service"))
                .route("recommender-service", r -> r.path("/api/v1/recommendations/**")
                        .uri("lb://recommender-service"))
                .route("user-service", r -> r.path("/api/v1/users/**")
                        .uri("lb://user-service"))
                .route("notification-service", r -> r.path("/api/v1/notifications/**")
                        .uri("lb://notification-service"))
                .build();
    }
}
