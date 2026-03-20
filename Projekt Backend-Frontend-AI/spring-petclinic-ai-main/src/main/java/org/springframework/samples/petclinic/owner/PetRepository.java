package org.springframework.samples.petclinic.owner;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface PetRepository extends JpaRepository<Pet, Integer> {

	@Query("SELECT p.type.name, COUNT(p) FROM Pet p GROUP BY p.type.name")
	List<Object[]> countPetsBySpecies();

	@Query("SELECT CONCAT(o.firstName, ' ', o.lastName), COUNT(p) FROM Pet p JOIN p.owner o GROUP BY o.id ORDER BY COUNT(p) DESC")
	List<Object[]> findTopOwnersByPetCount();

	Page<Pet> findByOwner_Id(Integer ownerId, Pageable pageable);

	Page<Pet> findByType_NameIgnoreCase(String type, Pageable pageable);

	Page<Pet> findByNameContainingIgnoreCase(String name, Pageable pageable);

}
