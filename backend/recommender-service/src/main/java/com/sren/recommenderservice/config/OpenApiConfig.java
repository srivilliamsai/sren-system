package com.sren.recommenderservice.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@OpenAPIDefinition(info = @Info(title = "SREN Recommender Service", version = "v1"))
public class OpenApiConfig {

    @Bean
    public GroupedOpenApi recommenderApi() {
        return GroupedOpenApi.builder()
                .group("recommender")
                .pathsToMatch("/api/v1/recommendations/**")
                .build();
    }
}
