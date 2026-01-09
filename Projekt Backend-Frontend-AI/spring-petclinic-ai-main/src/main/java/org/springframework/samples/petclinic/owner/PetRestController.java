package org.springframework.samples.petclinic.owner;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/pets")
public class PetRestController {
    @Autowired
    private PetRepository petRepository;

    @GetMapping
    public List<Pet> getAllPets() {
        return petRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Pet> getPetById(@PathVariable Integer id) {
        Optional<Pet> pet = petRepository.findById(id);
        return pet.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public Pet createPet(@RequestBody Pet pet) {
        return petRepository.save(pet);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Pet> updatePet(@PathVariable Integer id, @RequestBody Pet petDetails) {
        Optional<Pet> petOptional = petRepository.findById(id);
        if (!petOptional.isPresent()) {
            return ResponseEntity.notFound().build();
        }
        Pet pet = petOptional.get();
        pet.setName(petDetails.getName());
        pet.setType(petDetails.getType());
        pet.setBirthDate(petDetails.getBirthDate());
        pet.setWeight(petDetails.getWeight());
        pet.setBreed(petDetails.getBreed());
        pet.setVaccinated(petDetails.getVaccinated());
        return ResponseEntity.ok(petRepository.save(pet));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePet(@PathVariable Integer id) {
        if (!petRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        petRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/age")
    public ResponseEntity<Integer> getPetAge(@PathVariable Integer id) {
        Optional<Pet> pet = petRepository.findById(id);
        return pet.map(p -> ResponseEntity.ok(p.getAge())).orElseGet(() -> ResponseEntity.notFound().build());
    }
}

