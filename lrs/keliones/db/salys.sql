DROP TABLE IF EXISTS states;

CREATE TABLE states (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120),
    iso_id VARCHAR(2),
    lng varchar(9),
    lat varchar(9),
    state_group_union varchar(9)
);