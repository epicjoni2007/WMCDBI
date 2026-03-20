package org.springframework.samples.petclinic.api.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.samples.petclinic.owner.OwnerRepository;
import org.springframework.samples.petclinic.vet.SpecialtyRepository;
import org.springframework.samples.petclinic.api.dto.OwnerDto;
import org.springframework.samples.petclinic.api.mapper.OwnerMapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public class AuxController {

	private final OwnerRepository ownerRepository;

	private final SpecialtyRepository specialtyRepository;

	public AuxController(OwnerRepository ownerRepository, SpecialtyRepository specialtyRepository) {
		this.ownerRepository = ownerRepository;
		this.specialtyRepository = specialtyRepository;
	}

	@GetMapping("/health")
	public ResponseEntity<Map<String, String>> health() {
		return ResponseEntity.ok(Map.of("status", "UP"));
	}

	@GetMapping("/specialties")
	public List<String> specialties() {
		return specialtyRepository.findAll().stream().map(s -> s.getName()).collect(Collectors.toList());
	}

	@GetMapping("/search/owners")
	public List<OwnerDto> searchOwners(@RequestParam("q") String q) {
		return ownerRepository.findByLastNameStartingWith(q, org.springframework.data.domain.PageRequest.of(0, 50))
			.stream()
			.map(o -> OwnerMapper.toDto(o))
			.collect(Collectors.toList());
	}

}
