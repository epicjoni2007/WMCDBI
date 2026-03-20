DROP TABLE IF EXISTS vet_specialties;
DROP TABLE IF EXISTS vets;
DROP TABLE IF EXISTS specialties;
DROP TABLE IF EXISTS visits;
DROP TABLE IF EXISTS pets;
DROP TABLE IF EXISTS types;
DROP TABLE IF EXISTS owners;


CREATE TABLE vets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(30),
  last_name VARCHAR(30)
);
CREATE INDEX idx_vets_last_name ON vets (last_name);

CREATE TABLE specialties (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80)
);
CREATE INDEX idx_specialties_name ON specialties (name);

CREATE TABLE vet_specialties (
  vet_id INT NOT NULL,
  specialty_id INT NOT NULL,
  PRIMARY KEY (vet_id, specialty_id),
  CONSTRAINT fk_vet_specialties_vets FOREIGN KEY (vet_id) REFERENCES vets (id),
  CONSTRAINT fk_vet_specialties_specialties FOREIGN KEY (specialty_id) REFERENCES specialties (id)
);

CREATE TABLE types (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80)
);
CREATE INDEX idx_types_name ON types (name);

CREATE TABLE owners (
  id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(30),
  last_name VARCHAR(30),
  address VARCHAR(255),
  city VARCHAR(80),
  telephone VARCHAR(20)
);
CREATE INDEX idx_owners_last_name ON owners (last_name);

CREATE TABLE pets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30),
  birth_date DATE,
  type_id INT NOT NULL,
  owner_id INT,
  weight DOUBLE,
  breed VARCHAR(255),
  vaccinated BOOLEAN DEFAULT FALSE,
  CONSTRAINT fk_pets_owners FOREIGN KEY (owner_id) REFERENCES owners (id),
  CONSTRAINT fk_pets_types FOREIGN KEY (type_id) REFERENCES types (id)
);
CREATE INDEX idx_pets_name ON pets (name);

CREATE TABLE visits (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pet_id INT,
  visit_date DATE,
  description VARCHAR(255),
  CONSTRAINT fk_visits_pets FOREIGN KEY (pet_id) REFERENCES pets (id)
);
CREATE INDEX idx_visits_pet_id ON visits (pet_id);
