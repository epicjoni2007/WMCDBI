package org.springframework.samples.petclinic.api.controller;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.samples.petclinic.api.dto.PetCreateDto;
import org.springframework.samples.petclinic.api.dto.PetDto;
import org.springframework.samples.petclinic.api.dto.PetUpdateDto;
import org.springframework.samples.petclinic.api.mapper.PetMapper;
import org.springframework.samples.petclinic.owner.Owner;
import org.springframework.samples.petclinic.owner.OwnerRepository;
import org.springframework.samples.petclinic.owner.Pet;
import org.springframework.samples.petclinic.owner.PetRepository;
import org.springframework.samples.petclinic.owner.PetType;
import org.springframework.samples.petclinic.owner.PetTypeRepository;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/pets")
public class PetApiController {

	private final PetRepository petRepository;

	private final OwnerRepository ownerRepository;

	private final PetTypeRepository petTypeRepository;

	public PetApiController(PetRepository petRepository, OwnerRepository ownerRepository,
			PetTypeRepository petTypeRepository) {
		this.petRepository = petRepository;
		this.ownerRepository = ownerRepository;
		this.petTypeRepository = petTypeRepository;
	}

	@GetMapping
	public Page<PetDto> listPets(@RequestParam(value = "ownerId", required = false) Long ownerId,
			@RequestParam(value = "type", required = false) String type,
			@RequestParam(value = "q", required = false) String q, @PageableDefault(size = 20) Pageable pageable) {
		if (ownerId != null) {
			return petRepository.findByOwner_Id(ownerId.intValue(), pageable).map(PetMapper::toDto);
		}
		if (type != null && !type.isEmpty()) {
			return petRepository.findByType_NameIgnoreCase(type, pageable).map(PetMapper::toDto);
		}
		if (q != null && !q.isEmpty()) {
			return petRepository.findByNameContainingIgnoreCase(q, pageable).map(PetMapper::toDto);
		}
		return petRepository.findAll(pageable).map(PetMapper::toDto);
	}

	@GetMapping("/{id}")
	public ResponseEntity<PetDto> getPet(@PathVariable Long id) {
		Optional<Pet> p = petRepository.findById(id.intValue());
		return p.map(pet -> ResponseEntity.ok(PetMapper.toDto(pet))).orElseGet(() -> ResponseEntity.notFound().build());
	}

	@GetMapping("/owners/{ownerId}/pets")
	public List<PetDto> listOwnerPets(@PathVariable Long ownerId) {
		Optional<Owner> o = ownerRepository.findById(ownerId.intValue());
		if (o.isEmpty())
			return List.of();
		return o.get().getPets().stream().map(PetMapper::toDto).collect(Collectors.toList());
	}

	@PostMapping
	public ResponseEntity<PetDto> createPet(@RequestBody PetCreateDto dto) {
		Optional<Owner> ownerOpt = ownerRepository.findById(dto.ownerId.intValue());
		if (ownerOpt.isEmpty())
			return ResponseEntity.badRequest().build();
		Owner owner = ownerOpt.get();
		Pet pet = new Pet();
		pet.setName(dto.name);
		pet.setBirthDate(dto.birthDate);
		// find or create PetType
		PetType type = petTypeRepository.findByNameIgnoreCase(dto.type).orElseGet(() -> {
			PetType t = new PetType();
			t.setName(dto.type);
			return petTypeRepository.save(t);
		});
		pet.setType(type);
		pet.setOwner(owner);
		owner.addPet(pet);
		ownerRepository.save(owner);
		PetDto pd = PetMapper.toDto(pet);
		return ResponseEntity.created(URI.create("/api/pets/" + pd.id)).body(pd);
	}

	@PutMapping("/{id}")
	public ResponseEntity<PetDto> updatePet(@PathVariable Long id, @RequestBody PetUpdateDto dto) {
		Optional<Pet> p = petRepository.findById(id.intValue());
		if (p.isEmpty())
			return ResponseEntity.notFound().build();
		Pet pet = p.get();
		if (dto.name != null)
			pet.setName(dto.name);
		if (dto.birthDate != null)
			pet.setBirthDate(dto.birthDate);
		if (dto.type != null) {
			PetType type = petTypeRepository.findByNameIgnoreCase(dto.type).orElseGet(() -> {
				PetType t = new PetType();
				t.setName(dto.type);
				return petTypeRepository.save(t);
			});
			pet.setType(type);
		}
		Pet saved = petRepository.save(pet);
		return ResponseEntity.ok(PetMapper.toDto(saved));
	}

	@PatchMapping("/{id}")
	public ResponseEntity<PetDto> patchPet(@PathVariable Long id, @RequestBody PetUpdateDto dto) {
		return updatePet(id, dto);
	}

	@DeleteMapping("/{id}")
	public ResponseEntity<Void> deletePet(@PathVariable Long id) {
		Optional<Pet> p = petRepository.findById(id.intValue());
		if (p.isEmpty())
			return ResponseEntity.notFound().build();
		petRepository.deleteById(id.intValue());
		return ResponseEntity.noContent().build();
	}

}
