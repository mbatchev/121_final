-- EVERYTHING THAT NEEDS TO BE FILLED IN AS A PARAMETER IS DENOTED
-- BY SQUARE BRACKETS OR BY THE INTEGER 00
-- THESE ARE ALL SELECT ONLY, ANY INSERTS WILL BE IN STORE PROCEDURES

-- GETS YOUR FEED
-- CONSISTS OF ALl REVIEWS POSTED BY YOU OR YOUR FRIENDS
SELECT username, review_content, star_rating, post_time 
FROM reviews as r
JOIN users USING(uid)
WHERE (r.uid = 00) 
    OR (SELECT COUNT(*) FROM friendships
        WHERE uid_1 = 00 AND uid_2 = r.uid) != 0;

-- GETS ALL MOVIES OR TV SHOWS THAT MATCH A SEARCH TERM
-- SEARCHES BY PREFIX TO PRESERVE INDEX USE
-- FOR EXAMPLE:
-- "breaking ba%" WOULD RETURN ALL TV SHOWS THAT START WITH 
-- "breaking ba" INCLUDING "Breaking Bad"
SELECT imdb_id, primaryTitle, releaseYear, runtimeMinutes
FROM titles 
WHERE primaryTitle LIKE "breaking ba%" -- placeholder search term
AND (titleType = "tvSeries" OR titleType = "movie");

-- SEARCH FOR A FRIEND BY USERNAME
-- USING A SIMILAR PREFIX SEARCH
SELECT uid, username 
FROM users 
WHERE username LIKE "u%"; -- placeholder search term

-- GETS YOUR UID GIVEN YOUR EXACT USERNAME
SELECT uid 
FROM users 
WHERE username = "u1"; -- placeholder username

-- GETS YOUR FRIENDS USERNAMES
SELECT username
FROM users as u 
WHERE (SELECT COUNT(*) FROM friendships
        WHERE uid_1 = 1 AND uid_2 = u.uid) != 0; -- "1" is a placeholder uid


-- GETS ALL REVIEWS OF A MOVE
SELECT rid, username, review_content, star_rating, post_time 
FROM reviews as r
JOIN users USING(uid)
WHERE r.imdb_id = "tt0829482"; -- placeholder imdb ID