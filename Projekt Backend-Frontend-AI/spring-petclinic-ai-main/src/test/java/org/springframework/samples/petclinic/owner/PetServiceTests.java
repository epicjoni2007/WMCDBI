package org.springframework.samples.petclinic.owner;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class PetServiceTests {

	@Mock
	private PetRepository petRepository;

	@InjectMocks
	private PetService petService;

	@BeforeEach
	void setUp() {
		MockitoAnnotations.openMocks(this);
	}

	@Test
	void testFindAll() {
		Pet pet1 = new Pet();
		Pet pet2 = new Pet();
		when(petRepository.findAll()).thenReturn(Arrays.asList(pet1, pet2));
		List<Pet> pets = petService.findAll();
		assertEquals(2, pets.size());
	}

	@Test
	void testFindByIdFound() {
		Pet pet = new Pet();
		when(petRepository.findById(1)).thenReturn(Optional.of(pet));
		Optional<Pet> result = petService.findById(1);
		assertTrue(result.isPresent());
	}

	@Test
	void testFindByIdNotFound() {
		when(petRepository.findById(1)).thenReturn(Optional.empty());
		Optional<Pet> result = petService.findById(1);
		assertFalse(result.isPresent());
	}

	@Test
	void testSave() {
		Pet pet = new Pet();
		when(petRepository.save(pet)).thenReturn(pet);
		Pet saved = petService.save(pet);
		assertEquals(pet, saved);
	}

	@Test
	void testDeleteById() {
		petService.deleteById(1);
		verify(petRepository, times(1)).deleteById(1);
	}

	@Test
	void testCalculateAgeWithBirthDate() {
		Pet pet = new Pet();
		pet.setBirthDate(LocalDate.now().minusYears(5));
		Integer age = petService.calculateAge(pet);
		assertEquals(5, age);
	}

	@Test
	void testCalculateAgeWithNullBirthDate() {
		Pet pet = new Pet();
		pet.setBirthDate(null);
		Integer age = petService.calculateAge(pet);
		assertNull(age);
	}

	@Test
	void testCalculateAgeWithTodayBirthDate() {
		Pet pet = new Pet();
		pet.setBirthDate(LocalDate.now());
		Integer age = petService.calculateAge(pet);
		assertEquals(0, age);
	}

}
