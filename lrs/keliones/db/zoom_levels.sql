DROP TABLE IF EXISTS zoom_levels;

CREATE TABLE zoom_levels (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    state_group_id INT NOT NULL,
    from_level INT NOT NULL,
    to_level INT NOT NULL
);