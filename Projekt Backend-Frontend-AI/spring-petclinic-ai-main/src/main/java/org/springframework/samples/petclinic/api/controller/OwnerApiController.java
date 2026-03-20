package org.springframework.samples.petclinic.api.controller;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.samples.petclinic.api.dto.OwnerCreateDto;
import org.springframework.samples.petclinic.api.dto.OwnerDto;
import org.springframework.samples.petclinic.api.dto.OwnerUpdateDto;
import org.springframework.samples.petclinic.api.mapper.OwnerMapper;
import org.springframework.samples.petclinic.owner.Owner;
import org.springframework.samples.petclinic.owner.OwnerRepository;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.Optional;

@RestController
@RequestMapping("/api/owners")
public class OwnerApiController {

	private final OwnerRepository ownerRepository;

	public OwnerApiController(OwnerRepository ownerRepository) {
		this.ownerRepository = ownerRepository;
	}

	@GetMapping
	public Page<OwnerDto> listOwners(@RequestParam(value = "q", required = false) String q,
			@RequestParam(value = "city", required = false) String city,
			@PageableDefault(size = 20) Pageable pageable) {
		Page<Owner> page;
		if (q != null && !q.isEmpty()) {
			page = ownerRepository.findByLastNameStartingWith(q, pageable);
		}
		else if (city != null && !city.isEmpty()) {
			page = ownerRepository.findByCityContainingIgnoreCase(city, pageable);
		}
		else {
			page = ownerRepository.findAll(pageable);
		}
		return page.map(o -> OwnerMapper.toDto(o));
	}

	@GetMapping("/{id}")
	public ResponseEntity<OwnerDto> getOwner(@PathVariable Long id,
			@RequestParam(value = "includePets", required = false, defaultValue = "false") boolean includePets) {
		Optional<Owner> o = ownerRepository.findById(id.intValue());
		return o.map(owner -> ResponseEntity.ok(OwnerMapper.toDto(owner, includePets)))
			.orElseGet(() -> ResponseEntity.notFound().build());
	}

	@PostMapping
	public ResponseEntity<OwnerDto> createOwner(@RequestBody OwnerCreateDto dto) {
		Owner owner = OwnerMapper.toEntity(dto);
		Owner saved = ownerRepository.save(owner);
		OwnerDto od = OwnerMapper.toDto(saved, true);
		return ResponseEntity.created(URI.create("/api/owners/" + od.id)).body(od);
	}

	@PutMapping("/{id}")
	public ResponseEntity<OwnerDto> updateOwner(@PathVariable Long id, @RequestBody OwnerUpdateDto dto) {
		Optional<Owner> o = ownerRepository.findById(id.intValue());
		if (o.isEmpty())
			return ResponseEntity.notFound().build();
		Owner owner = o.get();
		OwnerMapper.updateEntity(owner, dto);
		Owner saved = ownerRepository.save(owner);
		return ResponseEntity.ok(OwnerMapper.toDto(saved, true));
	}

	@PatchMapping("/{id}")
	public ResponseEntity<OwnerDto> patchOwner(@PathVariable Long id, @RequestBody OwnerUpdateDto dto) {
		return updateOwner(id, dto);
	}

	@DeleteMapping("/{id}")
	public ResponseEntity<Void> deleteOwner(@PathVariable Long id) {
		Optional<Owner> o = ownerRepository.findById(id.intValue());
		if (o.isEmpty())
			return ResponseEntity.notFound().build();
		ownerRepository.deleteById(id.intValue());
		return ResponseEntity.noContent().build();
	}

}
