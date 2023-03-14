
DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS friendships;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS titles;

-- table that stores all of the movies & tv shows and their information
CREATE TABLE titles (
    -- unique identifier provided by imbdb
    imdb_id VARCHAR(9),
     -- identifies what type the title is, "short", "movie", etc
    titleType VARCHAR(12),
     -- the name of the title 
    primaryTitle VARCHAR(100),
    releaseYear YEAR,
    runtimeMinutes INT,
    PRIMARY KEY (imdb_id)
);

-- stores user accounts
CREATE TABLE users (
    uid BIGINT UNSIGNED AUTO_INCREMENT,
    username VARCHAR(20) NOT NULL,
    join_date DATETIME NOT NULL,
    password VARCHAR(25) NOT NULL,
    PRIMARY KEY (uid)
);

-- stores friendships between user accounts
-- for each friendship, store both directions, ie,
-- (friendA, friendB) and (friendB, friendA) shoul always be in the table
CREATE TABLE friendships (
    uid_1 BIGINT UNSIGNED,
    uid_2 BIGINT UNSIGNED,
    PRIMARY KEY (uid_1, uid_2),
    FOREIGN KEY (uid_1) 
        REFERENCES users(uid)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (uid_2) 
        REFERENCES users(uid)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- these are the user's posts that they share with their friends
CREATE TABLE reviews (
    -- auto generated ID of this review
    rid BIGINT UNSIGNED AUTO_INCREMENT,
    -- uid of the user that create it 
    uid BIGINT UNSIGNED NOT NULL,
    -- id of the movie or show that it is about
    imdb_id VARCHAR(9) NOT NULL,
    post_time DATETIME NOT NULL,
    review_content VARCHAR(2000) NOT NULL,
    -- can be 1 to 5
    star_rating INT,
    PRIMARY KEY (rid),
    FOREIGN KEY (uid)
        REFERENCES users(uid)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (imdb_id)
        REFERENCES titles(imdb_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- stores likes that a user made on another user's review
CREATE TABLE likes (
    uid BIGINT UNSIGNED,
    rid BIGINT UNSIGNED,
    PRIMARY KEY (uid, rid),
    FOREIGN KEY (uid)
        REFERENCES users(uid)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (rid)
        REFERENCES reviews(rid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- allows for quicker searching of movies by their name
ALTER TABLE titles ADD INDEX (primaryTitle);