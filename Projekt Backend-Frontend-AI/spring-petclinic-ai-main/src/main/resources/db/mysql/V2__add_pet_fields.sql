-- Migration für neue Felder in der Tabelle pets
ALTER TABLE pets
ADD COLUMN weight DOUBLE,
ADD COLUMN breed VARCHAR(255),
ADD COLUMN vaccinated BOOLEAN;
