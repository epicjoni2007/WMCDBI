package org.springframework.samples.petclinic.owner;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Map;

public interface PetRepository extends JpaRepository<Pet, Integer> {
    @Query("SELECT p.type.name, COUNT(p) FROM Pet p GROUP BY p.type.name")
    List<Object[]> countPetsBySpecies();

    @Query("SELECT p.owner.id, COUNT(p) FROM Pet p GROUP BY p.owner.id ORDER BY COUNT(p) DESC")
    List<Object[]> findTopOwnersByPetCount();
}
