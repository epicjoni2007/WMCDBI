package org.springframework.samples.petclinic.api.mapper;

import org.springframework.samples.petclinic.api.dto.VisitDto;
import org.springframework.samples.petclinic.owner.Visit;

public class VisitMapper {

	public static VisitDto toDto(Visit v) {
		if (v == null)
			return null;
		VisitDto d = new VisitDto();
		d.id = v.getId() != null ? v.getId().longValue() : null;
		// Visit entity in this project is stored on the Pet side (JoinColumn in Pet),
		// so Visit does not have a reference to petId or vetId. Leave them null here.
		d.petId = null;
		d.vetId = null;
		d.date = v.getDate();
		d.description = v.getDescription();
		return d;
	}

}
