-- File for Password Management section of Final Project

-- (Provided) This function generates a specified number of characters for using as a
-- salt in passwords.
DROP FUNCTION IF EXISTS make_salt;
DELIMITER !
CREATE FUNCTION make_salt(num_chars INT) 
RETURNS VARCHAR(20) DETERMINISTIC
BEGIN
    DECLARE salt VARCHAR(20) DEFAULT '';

    -- Don't want to generate more than 20 characters of salt.
    SET num_chars = LEAST(20, num_chars);

    -- Generate the salt!  Characters used are ASCII code 32 (space)
    -- through 126 ('z').
    WHILE num_chars > 0 DO
        SET salt = CONCAT(salt, CHAR(32 + FLOOR(RAND() * 95)));
        SET num_chars = num_chars - 1;
    END WHILE;

    RETURN salt;
END !
DELIMITER ;

DROP TABLE IF EXISTS user_info;
-- This table holds information for authenticating users based on
-- a password.  Passwords are not stored plaintext so that they
-- cannot be used by people that shouldn't have them.
-- uid is a foreign key to the users table defined in the create.sql
-- file, where their non-sensitive account info is stored
CREATE TABLE user_info (
    uid BIGINT UNSIGNED PRIMARY KEY,

    -- Salt will be 8 characters all the time, so we can make this 8.
    salt CHAR(8) NOT NULL,

    -- We use SHA-2 with 256-bit hashes.  MySQL returns the hash
    -- value as a hexadecimal string, which means that each byte is
    -- represented as 2 characters.  Thus, 256 / 8 * 2 = 64.
    -- We can use BINARY or CHAR here; BINARY simply has a different
    -- definition for comparison/sorting than CHAR.
    password_hash BINARY(64) NOT NULL,
    FOREIGN KEY (uid)
        REFERENCES users(uid)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- [Problem 1a]
-- Adds a new user to the user_info table, using the specified password (max
-- of 20 characters). Salts the password with a newly-generated salt value,
-- and then the salt and hash values are both stored in the table.
DROP PROCEDURE IF EXISTS sp_add_user;
DELIMITER !
CREATE PROCEDURE sp_add_user(uid BIGINT UNSIGNED, password VARCHAR(20))
BEGIN
  DECLARE salt VARCHAR(8) DEFAULT make_salt(8);
  DECLARE hsh BINARY(64) DEFAULT SHA2(CONCAT(salt, password), 256);
  INSERT INTO user_info VALUES (uid, salt, hsh);
END !
DELIMITER ;

-- [Problem 1b]
-- Authenticates the specified username and password against the data
-- in the user_info table.  Returns 1 if the user appears in the table, and the
-- specified password hashes to the value for the user. Otherwise returns 0.
DROP FUNCTION IF EXISTS authenticate;
DELIMITER !
CREATE FUNCTION authenticate(in_uid BIGINT UNSIGNED, password VARCHAR(20))
RETURNS TINYINT DETERMINISTIC
BEGIN
    DECLARE salt VARCHAR(8) DEFAULT 
      (SELECT salt FROM user_info WHERE in_uid = uid);
    DECLARE hsh BINARY(64) DEFAULT SHA2(CONCAT(salt, password), 256);
    DECLARE stored_hash BINARY(64) DEFAULT 
      (SELECT password_hash FROM user_info WHERE in_uid = uid);
    IF hsh = stored_hash THEN 
      RETURN 1;
    ELSE 
      RETURN 0;
    END IF;
END !
DELIMITER ;

-- [Problem 1c]
-- NOTE: CREATE.SQL MUST BE RUN BEFORE THIS IN ORDER FOR THE EXAMPLE USERS TO EXIST
-- AND THUS FOR THE FOREIGN KEY CONSTRAINT TO BE SATISFIED
CALL sp_add_user(1, "password");
CALL sp_add_user(2, "123456");


-- [Problem 1d]
-- Optional: Create a procedure sp_change_password to generate a new salt and change the given
-- user's password to the given password (after salting and hashing)
DROP PROCEDURE IF EXISTS sp_update_user;
DELIMITER !
CREATE PROCEDURE sp_update_user(in_uid BIGINT UNSIGNED, password VARCHAR(20))
BEGIN
  DECLARE new_salt VARCHAR(8) DEFAULT make_salt(8);
  DECLARE hsh BINARY(64) DEFAULT SHA2(CONCAT(new_salt, password), 256);

  UPDATE user_info SET salt = new_salt, password_hash = hsh 
    WHERE uid = in_uid;
END !
DELIMITER ;