DROP TABLE IF EXISTS mp_caches;

CREATE TABLE mp_caches (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    mp_id int not null,
    trip_duration int
);

