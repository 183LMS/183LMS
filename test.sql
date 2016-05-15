#test
CREATE TABLE IF NOT EXISTS people(
person_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
firstname TEXT NOT NULL,
lastname TEXT NOT NULL,
major TEXT NOT NULL
);

INSERT INTO people (firstname, lastname, major)
VALUES ("Jay", "Song", "Computer Science");

INSERT INTO people (firstname, lastname, major)
VALUES ("Kevin", "Yang", "Computer Engineering");

INSERT INTO people (firstname, lastname, major)
VALUES ("Brandon", "Lu", "Electrical Engineering");

INSERT INTO people (firstname, lastname, major)
VALUES ("Kenneth", "Chan", "Computer Engineering");
