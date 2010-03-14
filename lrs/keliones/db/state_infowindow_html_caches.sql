DROP TABLE IF EXISTS state_infowindow_html_caches;

CREATE TABLE state_infowindow_html_caches (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    state_id int not null,
    html text
);