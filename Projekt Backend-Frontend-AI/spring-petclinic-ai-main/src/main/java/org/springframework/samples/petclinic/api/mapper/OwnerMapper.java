package org.springframework.samples.petclinic.api.mapper;

import org.springframework.samples.petclinic.api.dto.OwnerCreateDto;
import org.springframework.samples.petclinic.api.dto.OwnerDto;
import org.springframework.samples.petclinic.api.dto.OwnerUpdateDto;
import org.springframework.samples.petclinic.owner.Owner;

import java.util.stream.Collectors;

public class OwnerMapper {

	public static OwnerDto toDto(Owner owner) {
		return toDto(owner, false);
	}

	public static OwnerDto toDto(Owner owner, boolean includePets) {
		if (owner == null)
			return null;
		OwnerDto dto = new OwnerDto();
		dto.id = owner.getId() != null ? owner.getId().longValue() : null;
		dto.firstName = owner.getFirstName();
		dto.lastName = owner.getLastName();
		dto.address = owner.getAddress();
		dto.city = owner.getCity();
		dto.telephone = owner.getTelephone();
		dto.email = owner.getEmail();
		if (includePets && owner.getPets() != null) {
			dto.pets = owner.getPets()
				.stream()
				.map(org.springframework.samples.petclinic.api.mapper.PetMapper::toDto)
				.collect(Collectors.toList());
		}
		return dto;
	}

	public static Owner toEntity(OwnerCreateDto dto) {
		if (dto == null)
			return null;
		Owner o = new Owner();
		o.setFirstName(dto.firstName);
		o.setLastName(dto.lastName);
		o.setAddress(dto.address);
		o.setCity(dto.city);
		o.setTelephone(dto.telephone);
		o.setEmail(dto.email);
		o.setPassword(dto.password);
		return o;
	}

	public static void updateEntity(Owner owner, OwnerUpdateDto dto) {
		if (dto.firstName != null)
			owner.setFirstName(dto.firstName);
		if (dto.lastName != null)
			owner.setLastName(dto.lastName);
		if (dto.address != null)
			owner.setAddress(dto.address);
		if (dto.city != null)
			owner.setCity(dto.city);
		if (dto.telephone != null)
			owner.setTelephone(dto.telephone);
		if (dto.email != null)
			owner.setEmail(dto.email);
	}

}
