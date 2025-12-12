package org.springframework.samples.petclinic.owner;

import java.time.LocalDate;

public class PetRequestDTO {
    private String name;
    private Integer typeId;
    private LocalDate birthDate;
    private Integer ownerId;
    private Double weight;
    private String breed;
    private String vaccinationStatus;

    // Getter und Setter
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Integer getTypeId() { return typeId; }
    public void setTypeId(Integer typeId) { this.typeId = typeId; }
    public LocalDate getBirthDate() { return birthDate; }
    public void setBirthDate(LocalDate birthDate) { this.birthDate = birthDate; }
    public Integer getOwnerId() { return ownerId; }
    public void setOwnerId(Integer ownerId) { this.ownerId = ownerId; }
    public Double getWeight() { return weight; }
    public void setWeight(Double weight) { this.weight = weight; }
    public String getBreed() { return breed; }
    public void setBreed(String breed) { this.breed = breed; }
    public String getVaccinationStatus() { return vaccinationStatus; }
    public void setVaccinationStatus(String vaccinationStatus) { this.vaccinationStatus = vaccinationStatus; }
}

