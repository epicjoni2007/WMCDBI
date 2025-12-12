package org.springframework.samples.petclinic.owner;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDate;
import java.time.Period;
import java.util.List;
import java.util.Optional;

@Service
public class PetService {
    private final PetRepository petRepository;

    @Autowired
    public PetService(PetRepository petRepository) {
        this.petRepository = petRepository;
    }

    public List<Pet> findAll() {
        return petRepository.findAll();
    }

    public Optional<Pet> findById(Integer id) {
        return petRepository.findById(id);
    }

    public Pet save(Pet pet) {
        return petRepository.save(pet);
    }

    public void deleteById(Integer id) {
        petRepository.deleteById(id);
    }

    public Integer calculateAge(Pet pet) {
        if (pet.getBirthDate() == null) return null;
        return Period.between(pet.getBirthDate(), LocalDate.now()).getYears();
    }
}
package org.springframework.samples.petclinic.owner;

import org.springframework.data.jpa.repository.JpaRepository;

public interface PetRepository extends JpaRepository<Pet, Integer> {
}

