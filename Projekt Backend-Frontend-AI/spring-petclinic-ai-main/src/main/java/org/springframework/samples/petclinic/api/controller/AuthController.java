package org.springframework.samples.petclinic.api.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.samples.petclinic.api.dto.*;
import org.springframework.samples.petclinic.api.service.AuthService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

	private final AuthService authService;

	public AuthController(AuthService authService) {
		this.authService = authService;
	}

	@PostMapping("/register")
	public ResponseEntity<AuthResponse> register(@RequestBody RegisterDto dto) {
		AuthResponse resp = authService.register(dto);
		return ResponseEntity.status(HttpStatus.CREATED).body(resp);
	}

	@PostMapping("/login")
	public ResponseEntity<?> login(@RequestBody LoginDto dto) {
		return authService.login(dto)
			.map(r -> ResponseEntity.ok(r))
			.orElseGet(() -> ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
	}

	@PostMapping("/refresh")
	public ResponseEntity<?> refresh(@RequestBody RefreshRequest req) {
		return authService.refresh(req.refreshToken)
			.map(r -> ResponseEntity.ok(r))
			.orElseGet(() -> ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
	}

	@PostMapping("/logout")
	public ResponseEntity<Void> logout(@RequestBody RefreshRequest req) {
		authService.logout(req.refreshToken);
		return ResponseEntity.noContent().build();
	}

}
