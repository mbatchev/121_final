-- CREATES YOUR ACCOUNT GIVEN A USERNAME
-- IF THE USERNAME IS NOT ALREADY TAKEN
-- ALSO HASHES AND STORES YOUR PASSWORD
-- RETURNS your new uid IF SUCCESFUL, 0 IF NOT
DROP PROCEDURE IF EXISTS sp_sign_up;
DELIMITER !
CREATE PROCEDURE sp_sign_up(in_username VARCHAR(20), password VARCHAR(20))
BEGIN
    DECLARE new_uid BIGINT UNSIGNED;
    IF (SELECT COUNT(*) FROM users as u WHERE u.username = in_username) = 0 THEN
        INSERT INTO users (username, join_date)
        VALUES (in_username, NOW());
        SET new_uid = LAST_INSERT_ID();
        CALL sp_add_user(new_uid, password);
        SELECT new_uid as uid;
    ELSE 
        SELECT 0 as uid; 
    END IF;
END !
DELIMITER ;

-- LOGS YOU IN GIVEN YOUR USERNAME AND PASSWORD
-- RETURNS YOUR UID IF SUCCESSFUL OR 0 OTHERWISE
DROP FUNCTION IF EXISTS log_in;
DELIMITER !
CREATE FUNCTION log_in(username VARCHAR(20), password VARCHAR(20))
RETURNS TINYINT DETERMINISTIC
BEGIN
    DECLARE your_uid BIGINT UNSIGNED;
    IF (SELECT COUNT(*) FROM users as u WHERE u.username = username) = 0 THEN
        RETURN 0;
    ELSE
        SET your_uid = (SELECT uid FROM users as u WHERE u.username = username); 
        IF authenticate(your_uid, password) = 1 THEN 
            RETURN your_uid;
        ELSE 
            RETURN 0;
        END IF;
        RETURN 0;
    END IF;
END !
DELIMITER ;


-- LIKES A REVIEW GIVEN ITS REVIEW ID
-- IF YOU ALREADY LIKED IT, JUST IGNORE
DROP PROCEDURE IF EXISTS sp_like_post;
DELIMITER !
CREATE PROCEDURE sp_like_post(in_uid BIGINT UNSIGNED, in_rid BIGINT UNSIGNED)
BEGIN
    IF (SELECT COUNT(*) FROM reviews WHERE rid = in_rid) = 0 THEN
        SELECT 0 as success;
    ELSE 
        INSERT IGNORE INTO likes VALUES (in_uid, in_rid);
        SELECT 1 as success;
    END IF;
END !
DELIMITER ;


-- CREATES A REVIEW OF A MOVIE GIVEN ITS imdb_id
-- RETURNS 1 IF SUCCESFUL, 0 IF NOT
DROP PROCEDURE IF EXISTS sp_create_post;
DELIMITER !
CREATE PROCEDURE sp_create_post(in_uid BIGINT UNSIGNED, 
                                in_imdb VARCHAR(10), 
                                txt VARCHAR(2000), 
                                stars INT)
BEGIN
    IF (SELECT COUNT(*) FROM titles WHERE imdb_id = in_imdb) = 0 THEN
        SELECT 0 as success;
    ELSE 
        INSERT INTO reviews (uid, imdb_id, review_content, star_rating, post_time)
        VALUES (in_uid, in_imdb, txt, stars, NOW());
        SELECT 1 as success;
    END IF;
END !
DELIMITER ;

-- FOR ADMINS:
-- MARKS A USER POST FOR DELETION BY STORING ITS INFO INTO A TABLE
-- A TRIGGER WILL THEN DELETE THE RELEVANT POST
DROP PROCEDURE IF EXISTS sp_delete_post;
DELIMITER !
CREATE PROCEDURE sp_delete_post(in_rid BIGINT UNSIGNED)
BEGIN
    DECLARE poster_uid BIGINT UNSIGNED;
    IF (SELECT COUNT(*) FROM reviews WHERE rid = in_rid) = 0 THEN
        SELECT 0 as success;
    ELSE 
        SET poster_uid = (SELECT uid FROM reviews WHERE rid = in_rid);
        INSERT IGNORE INTO marked_deletion VALUES (in_rid, poster_uid, NOW());
        SELECT 1 as success;
    END IF;
END !
DELIMITER ;

-- THIS TRIGGER WAITS FOR sp_delete_post TO BE CALLED
-- AFTER A POST IS MARKED FOR DELETION,
-- THIS TRIGGER DELETES THE POST
DELIMITER !
CREATE TRIGGER trig_delete_post 
    AFTER INSERT ON marked_deletion FOR EACH ROW 
    BEGIN
        DELETE FROM reviews WHERE rid = NEW.rid;
    END! 
DELIMITER ;