package org.springframework.samples.petclinic.api.dto;

import java.time.LocalDate;

public class VisitDto {

	public Long id;

	public Long petId;

	public Long vetId;

	public LocalDate date;

	public String description;

}
