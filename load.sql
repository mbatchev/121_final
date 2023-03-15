-- FIRST, LOAD IMDB MOVIE DATA
LOAD DATA LOCAL INFILE 'out.csv' INTO TABLE titles
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

-- To facilitate importing, We set these values to 0
-- need to change them to null now
UPDATE titles SET releaseYear = Null 
WHERE releaseYear = 0;

UPDATE titles SET runtimeMinutes = Null 
WHERE runtimeMinutes = 0;

-- NEXT, INSERT SOME EXAMPLE USER DATA
INSERT INTO users (username, join_date)
VALUES ("u1", NOW()),
       ("u2", NOW() - INTERVAL 1 DAY ),
       ("u3", NOW() - INTERVAL 2 DAY),
       ("u4", NOW() - INTERVAL 3 DAY),
       ("u5", NOW() - INTERVAL 4 DAY);