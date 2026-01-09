-- Migration für neue Felder in der Tabelle pets
ALTER TABLE pets
ADD COLUMN weight DOUBLE,
ADD COLUMN breed VARCHAR(255),
ADD COLUMN vaccinated BOOLEAN,
ADD COLUMN owner_id INTEGER;

-- Optional: Fremdschlüssel für owner_id
ALTER TABLE pets
ADD CONSTRAINT fk_pets_owner FOREIGN KEY (owner_id) REFERENCES owners(id);

