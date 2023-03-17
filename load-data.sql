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
INSERT INTO users (username, join_date, is_admin)
VALUES ("u1", NOW(), 1),
       ("u2", NOW() - INTERVAL 1 DAY , 0),
       ("u3", NOW() - INTERVAL 2 DAY, 0),
       ("u4", NOW() - INTERVAL 3 DAY, 0),
       ("u5", NOW() - INTERVAL 4 DAY, 0);

-- INSERT FRIENDSHIPS BETWEEN 2 MAIN TEST USERS
INSERT INTO friendships (uid_1, uid_2)
VALUES (1,2),
       (2,1);

-- SAMPLE REVIEWS LEFT BY 2 MAIN TEST USERS AND ONE LEFT BY "STRANGER"
INSERT INTO reviews (uid, imdb_id, post_time, review_content, star_rating)
VALUES (1, "tt0829482", NOW() - INTERVAL 1 HOUR, "Watched superbad 5/5 ", 5),
       (2, "tt0829482", NOW() - INTERVAL 5 MINUTE, "Didn't like superbad", 1),
       (1, "tt0903747", NOW() - INTERVAL 10 HOUR, "bravo vince", 5),
       (3, "tt0101120", NOW() - INTERVAL 1 HOUR, "tim the tool man taylor", 5);

INSERT INTO likes (uid, rid)
VALUES (1, 1), -- user 1 likes their own post 
       (1, 2); -- user 1 likes post id 2