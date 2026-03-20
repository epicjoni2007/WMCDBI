package org.springframework.samples.petclinic.api.mapper;

import org.springframework.samples.petclinic.api.dto.VetDto;
import org.springframework.samples.petclinic.vet.Vet;
import java.util.stream.Collectors;

public class VetMapper {

	public static VetDto toDto(Vet v) {
		if (v == null)
			return null;
		VetDto d = new VetDto();
		d.id = v.getId() != null ? v.getId().longValue() : null;
		d.firstName = v.getFirstName();
		d.lastName = v.getLastName();
		if (v.getSpecialties() != null) {
			d.specialties = v.getSpecialties().stream().map(s -> s.getName()).collect(Collectors.toList());
		}
		return d;
	}

}
