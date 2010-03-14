DROP TABLE trips;

CREATE TABLE trips (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    state VARCHAR(100),
    start_date DATE,
    end_date DATE,
    mp VARCHAR(100),
    kind VARCHAR(20)
);