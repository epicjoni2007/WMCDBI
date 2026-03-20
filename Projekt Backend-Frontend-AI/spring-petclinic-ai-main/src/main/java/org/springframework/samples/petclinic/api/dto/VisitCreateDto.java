package org.springframework.samples.petclinic.api.dto;

import java.time.LocalDate;

public class VisitCreateDto {

	public Long petId;

	public Long vetId;

	public LocalDate date;

	public String description;

}
