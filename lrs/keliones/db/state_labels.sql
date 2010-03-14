DROP TABLE IF EXISTS state_labels;

CREATE TABLE state_labels (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    label VARCHAR(120),
    state_id INT NOT NULL
);