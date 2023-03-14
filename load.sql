
-- LOAD DATA LOCAL INFILE 'titles_edit.tsv' INTO TABLE titles IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'out.csv' INTO TABLE titles
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

-- To facilitate importing, We set these values to 0
-- need to change them to null now
UPDATE titles SET releaseYear = Null 
WHERE releaseYear = 0;

UPDATE titles SET runtimeMinutes = Null 
WHERE runtimeMinutes = 0;
