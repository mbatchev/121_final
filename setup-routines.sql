-- CREATES YOUR ACCOUNT GIVEN A USERNAME
-- IF THE USERNAME IS NOT ALREADY TAKEN
-- ALSO HASHES AND STORES YOUR PASSWORD
-- RETURNS your new uid IF SUCCESFUL, 0 IF NOT
DROP PROCEDURE IF EXISTS sp_sign_up;
DELIMITER !
CREATE PROCEDURE sp_sign_up(username VARCHAR(20), password VARCHAR(20))
BEGIN
    DECLARE new_uid BIGINT UNSIGNED;
    IF (SELECT COUNT(*) FROM users as u WHERE u.username = username) = 0 THEN
        INSERT INTO users (username, join_date)
        VALUES (username, NOW());
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
        RETURN 0 as uid;
    ELSE
        SET your_uid = (SELECT uid FROM users as u WHERE u.username = username); 
        IF authenticate(your_uid, password) = 1 THEN 
            RETURN your_uid as uid;
        ELSE 
            RETURN 0 as uid;
        END IF;
        RETURN 0 as uid;
    END IF;
END !
DELIMITER ;


-- LIKES A REVIEW GIVEN ITS REVIEW ID
DROP PROCEDURE IF EXISTS sp_like_post;
DELIMITER !
CREATE PROCEDURE sp_like_post(in_uid BIGINT UNSIGNED, in_rid BIGINT UNSIGNED)
BEGIN
    IF (SELECT COUNT(*) FROM reviews WHERE rid = in_rid) = 0 THEN
        SELECT 0 as success;
    ELSE 
        INSERT INTO likes VALUES (in_uid, in_rid);
        SELECT 1 as success;
    END IF;
END !
DELIMITER ;


-- CREATES A REVIEW OF A MOVIE GIVEN ITS imdb_id
-- RETURNS 1 IF SUCCESFUL, 0 IF NOT
DROP PROCEDURE IF EXISTS sp_create_post;
DELIMITER !
CREATE PROCEDURE sp_create_post(in_uid BIGINT UNSIGNED, 
                                in_imbd VARCHAR(10), 
                                txt VARCHAR(2000), 
                                stars INT)
BEGIN
    IF (SELECT COUNT(*) FROM titles WHERE imdb_id = in_imdb) = 0 THEN
        SELECT 0 as success;
    ELSE 
        INSERT INTO reviews (uid, imdb_id, review_content, star_rating, post_time)
        VALUES (in_uid, in_imbd, txt, stars, NOW());
        SELECT 1 as success;
    END IF;
END !
DELIMITER ;