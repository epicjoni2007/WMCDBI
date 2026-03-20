package org.springframework.samples.petclinic.api.dto;

public class AuthResponse {

	public String accessToken;

	public String refreshToken;

	public long expiresIn; // seconds

	public OwnerDto user;

}
