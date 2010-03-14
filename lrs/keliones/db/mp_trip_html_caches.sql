DROP TABLE IF EXISTS mp_trip_html_caches;

CREATE TABLE mp_trip_html_caches (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    trip_id int not null,
    html varchar(160)
);