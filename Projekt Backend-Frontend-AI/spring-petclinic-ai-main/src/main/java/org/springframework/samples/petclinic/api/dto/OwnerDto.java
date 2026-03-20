package org.springframework.samples.petclinic.api.dto;

import java.util.List;

public class OwnerDto {

	public Long id;

	public String firstName;

	public String lastName;

	public String address;

	public String city;

	public String telephone;

	public String email;

	public List<PetDto> pets;

}
