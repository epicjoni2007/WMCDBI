package org.springframework.samples.petclinic.api.service;

import org.springframework.samples.petclinic.api.dto.*;
import org.springframework.samples.petclinic.owner.Owner;
import org.springframework.samples.petclinic.owner.OwnerRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class AuthService {

	private final OwnerRepository ownerRepository;

	private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

	// simple in-memory refresh-token store: token -> ownerId + expiry
	private final Map<String, RefreshInfo> refreshStore = new ConcurrentHashMap<>();

	public AuthService(OwnerRepository ownerRepository) {
		this.ownerRepository = ownerRepository;
	}

	public AuthResponse register(RegisterDto dto) {
		Owner o = new Owner();
		o.setFirstName(dto.firstName);
		o.setLastName(dto.lastName);
		o.setAddress(dto.address);
		o.setCity(dto.city);
		o.setTelephone(dto.telephone);
		o.setEmail(dto.email);
		o.setPassword(passwordEncoder.encode(dto.password));
		// default role
		o.getRoles().add("ROLE_USER");
		Owner saved = ownerRepository.save(o);

		return buildAuthResponse(saved);
	}

	public Optional<AuthResponse> login(LoginDto dto) {
		Optional<Owner> ownerOpt = ownerRepository.findByEmail(dto.email);
		if (ownerOpt.isEmpty())
			return Optional.empty();
		Owner owner = ownerOpt.get();
		if (!passwordEncoder.matches(dto.password, owner.getPassword()))
			return Optional.empty();
		return Optional.of(buildAuthResponse(owner));
	}

	public Optional<AuthResponse> refresh(String refreshToken) {
		RefreshInfo info = refreshStore.get(refreshToken);
		if (info == null)
			return Optional.empty();
		if (info.expiresAt.isBefore(Instant.now())) {
			refreshStore.remove(refreshToken);
			return Optional.empty();
		}
		Optional<Owner> ownerOpt = ownerRepository.findById(info.ownerId.intValue());
		if (ownerOpt.isEmpty())
			return Optional.empty();
		return Optional.of(buildAuthResponse(ownerOpt.get()));
	}

	public void logout(String refreshToken) {
		if (refreshToken != null)
			refreshStore.remove(refreshToken);
	}

	private AuthResponse buildAuthResponse(Owner owner) {
		AuthResponse resp = new AuthResponse();
		resp.user = new org.springframework.samples.petclinic.api.dto.OwnerDto();
		resp.user.id = owner.getId() != null ? owner.getId().longValue() : null;
		resp.user.firstName = owner.getFirstName();
		resp.user.lastName = owner.getLastName();
		resp.user.address = owner.getAddress();
		resp.user.city = owner.getCity();
		resp.user.telephone = owner.getTelephone();
		resp.user.email = owner.getEmail();

		String accessToken = UUID.randomUUID().toString();
		String refreshToken = UUID.randomUUID().toString();
		long expiresIn = 3600L; // 1h
		resp.accessToken = accessToken;
		resp.refreshToken = refreshToken;
		resp.expiresIn = expiresIn;

		// store refresh token (expiry 7 days)
		RefreshInfo info = new RefreshInfo(owner.getId() != null ? owner.getId().longValue() : -1L,
				Instant.now().plusSeconds(7 * 24 * 3600L));
		refreshStore.put(refreshToken, info);
		return resp;
	}

	private static class RefreshInfo {

		final Long ownerId;

		final Instant expiresAt;

		RefreshInfo(Long ownerId, Instant expiresAt) {
			this.ownerId = ownerId;
			this.expiresAt = expiresAt;
		}

	}

}
