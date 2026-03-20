package org.springframework.samples.petclinic.api.controller;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.samples.petclinic.api.dto.VetDto;
import org.springframework.samples.petclinic.api.mapper.VetMapper;
import org.springframework.samples.petclinic.vet.Vet;
import org.springframework.samples.petclinic.vet.VetRepository;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.Optional;

@RestController
@RequestMapping("/api/vets")
public class VetApiController {

	private final VetRepository vetRepository;

	public VetApiController(VetRepository vetRepository) {
		this.vetRepository = vetRepository;
	}

	@GetMapping
	public Page<VetDto> listVets(@PageableDefault(size = 20) Pageable pageable) {
		return vetRepository.findAll(pageable).map(VetMapper::toDto);
	}

	@GetMapping("/{id}")
	public ResponseEntity<VetDto> getVet(@PathVariable Long id) {
		Optional<Vet> v = vetRepository.findById(id.intValue());
		return v.map(ve -> ResponseEntity.ok(VetMapper.toDto(ve))).orElseGet(() -> ResponseEntity.notFound().build());
	}

	@PostMapping
	public ResponseEntity<VetDto> createVet(@RequestBody VetDto dto) {
		Vet v = new Vet();
		v.setFirstName(dto.firstName);
		v.setLastName(dto.lastName);
		Vet saved = vetRepository.save(v);
		VetDto out = VetMapper.toDto(saved);
		return ResponseEntity.created(URI.create("/api/vets/" + out.id)).body(out);
	}

	@PutMapping("/{id}")
	public ResponseEntity<VetDto> updateVet(@PathVariable Long id, @RequestBody VetDto dto) {
		Optional<Vet> vOpt = vetRepository.findById(id.intValue());
		if (vOpt.isEmpty())
			return ResponseEntity.notFound().build();
		Vet v = vOpt.get();
		if (dto.firstName != null)
			v.setFirstName(dto.firstName);
		if (dto.lastName != null)
			v.setLastName(dto.lastName);
		Vet saved = vetRepository.save(v);
		return ResponseEntity.ok(VetMapper.toDto(saved));
	}

	@PatchMapping("/{id}")
	public ResponseEntity<VetDto> patchVet(@PathVariable Long id, @RequestBody VetDto dto) {
		return updateVet(id, dto);
	}

	@DeleteMapping("/{id}")
	public ResponseEntity<Void> deleteVet(@PathVariable Long id) {
		if (!vetRepository.existsById(id.intValue()))
			return ResponseEntity.notFound().build();
		vetRepository.deleteById(id.intValue());
		return ResponseEntity.noContent().build();
	}

}
