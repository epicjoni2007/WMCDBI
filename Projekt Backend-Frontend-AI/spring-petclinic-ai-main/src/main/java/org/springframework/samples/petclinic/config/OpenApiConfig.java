package org.springframework.samples.petclinic.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

	@Bean
	public OpenAPI springPetClinicOpenAPI() {
		return new OpenAPI().info(new Info().title("Spring PetClinic API")
			.version("v1")
			.description("OpenAPI/Swagger UI for the Spring PetClinic application"));
	}

}
