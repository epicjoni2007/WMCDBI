package org.springframework.samples.petclinic.api.controller;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.samples.petclinic.api.dto.VisitCreateDto;
import org.springframework.samples.petclinic.api.dto.VisitDto;
import org.springframework.samples.petclinic.api.mapper.VisitMapper;
import org.springframework.samples.petclinic.owner.Owner;
import org.springframework.samples.petclinic.owner.OwnerRepository;
import org.springframework.samples.petclinic.owner.Pet;
import org.springframework.samples.petclinic.owner.PetRepository;
import org.springframework.samples.petclinic.owner.Visit;
import org.springframework.samples.petclinic.visit.VisitRepository;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/visits")
public class VisitApiController {

	private final VisitRepository visitRepository;

	private final PetRepository petRepository;

	private final OwnerRepository ownerRepository;

	public VisitApiController(VisitRepository visitRepository, PetRepository petRepository,
			OwnerRepository ownerRepository) {
		this.visitRepository = visitRepository;
		this.petRepository = petRepository;
		this.ownerRepository = ownerRepository;
	}

	@GetMapping
	public Page<VisitDto> listVisits(@RequestParam(value = "petId", required = false) Long petId,
			@RequestParam(value = "date", required = false) String date,
			@PageableDefault(size = 20) Pageable pageable) {
		if (petId != null) {
			// visits are stored on pet; fetch pet and map visits manually
			Optional<Pet> pet = petRepository.findById(petId.intValue());
			if (pet.isEmpty())
				return Page.empty(pageable);
			List<VisitDto> list = pet.get().getVisits().stream().map(VisitMapper::toDto).collect(Collectors.toList());
			return new PageImpl<>(list, pageable, list.size());
		}
		if (date != null && !date.isEmpty()) {
			LocalDate d = LocalDate.parse(date);
			List<VisitDto> list = visitRepository.findAll()
				.stream()
				.filter(v -> d.equals(v.getDate()))
				.map(VisitMapper::toDto)
				.collect(Collectors.toList());
			return new PageImpl<>(list, pageable, list.size());
		}
		return visitRepository.findAll(pageable).map(VisitMapper::toDto);
	}

	@GetMapping("/{id}")
	public ResponseEntity<VisitDto> getVisit(@PathVariable Long id) {
		Optional<Visit> v = visitRepository.findById(id.intValue());
		return v.map(vis -> ResponseEntity.ok(VisitMapper.toDto(vis)))
			.orElseGet(() -> ResponseEntity.notFound().build());
	}

	@GetMapping("/owners/{ownerId}/visits")
	public List<VisitDto> listOwnerVisits(@PathVariable Long ownerId) {
		Optional<Owner> ownerOpt = ownerRepository.findById(ownerId.intValue());
		if (ownerOpt.isEmpty())
			return List.of();
		Owner owner = ownerOpt.get();
		return owner.getPets()
			.stream()
			.flatMap(p -> p.getVisits().stream())
			.map(VisitMapper::toDto)
			.collect(Collectors.toList());
	}

	@PostMapping
	public ResponseEntity<VisitDto> createVisit(@RequestBody VisitCreateDto dto) {
		if (dto.petId == null)
			return ResponseEntity.badRequest().build();
		Optional<Pet> petOpt = petRepository.findById(dto.petId.intValue());
		if (petOpt.isEmpty())
			return ResponseEntity.badRequest().build();
		Pet pet = petOpt.get();
		Visit visit = new Visit();
		if (dto.date != null)
			visit.setDate(dto.date);
		visit.setDescription(dto.description != null ? dto.description : "");
		pet.addVisit(visit);
		petRepository.save(pet);
		VisitDto out = VisitMapper.toDto(visit);
		return ResponseEntity.created(URI.create("/api/visits/" + out.id)).body(out);
	}

	@PutMapping("/{id}")
	public ResponseEntity<VisitDto> updateVisit(@PathVariable Long id, @RequestBody VisitCreateDto dto) {
		Optional<Visit> v = visitRepository.findById(id.intValue());
		if (v.isEmpty())
			return ResponseEntity.notFound().build();
		Visit visit = v.get();
		if (dto.date != null)
			visit.setDate(dto.date);
		if (dto.description != null)
			visit.setDescription(dto.description);
		Visit saved = visitRepository.save(visit);
		return ResponseEntity.ok(VisitMapper.toDto(saved));
	}

	@DeleteMapping("/{id}")
	public ResponseEntity<Void> deleteVisit(@PathVariable Long id) {
		if (!visitRepository.existsById(id.intValue()))
			return ResponseEntity.notFound().build();
		visitRepository.deleteById(id.intValue());
		return ResponseEntity.noContent().build();
	}

}
