package org.springframework.samples.petclinic.api.mapper;

import org.springframework.samples.petclinic.api.dto.PetDto;
import org.springframework.samples.petclinic.owner.Pet;

public class PetMapper {

	public static PetDto toDto(Pet pet) {
		if (pet == null)
			return null;
		PetDto d = new PetDto();
		d.id = pet.getId() != null ? pet.getId().longValue() : null;
		d.name = pet.getName();
		d.birthDate = pet.getBirthDate();
		d.type = pet.getType() != null ? pet.getType().getName() : null;
		d.ownerId = pet.getOwner() != null
				? (pet.getOwner().getId() != null ? pet.getOwner().getId().longValue() : null) : null;
		return d;
	}

}
