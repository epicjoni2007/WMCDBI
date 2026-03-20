package org.springframework.samples.petclinic.api.dto;

import java.time.LocalDate;

public class PetCreateDto {

	public String name;

	public LocalDate birthDate;

	public String type;

	public Long ownerId;

}
