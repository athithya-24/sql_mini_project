
CREATE DATABASE IF NOT EXISTS movie_db;
USE movie_db;

DROP TABLE IF EXISTS Watch_History;
DROP TABLE IF EXISTS Ratings;
DROP TABLE IF EXISTS Movies;
DROP TABLE IF EXISTS Users;

-- USERS TABLE
CREATE TABLE Users(
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- MOVIES TABLE
CREATE TABLE Movies(
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    genre VARCHAR(100) NOT NULL
);

-- RATINGS TABLE
CREATE TABLE Ratings(
    user_id INT,
    movie_id INT,
    rating FLOAT CHECK (rating BETWEEN 1 AND 5),
    PRIMARY KEY(user_id, movie_id),
    FOREIGN KEY(user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY(movie_id) REFERENCES Movies(movie_id) ON DELETE CASCADE
);

-- WATCH HISTORY TABLE
CREATE TABLE Watch_History(
    user_id INT,
    movie_id INT,
    watch_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY(user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY(movie_id) REFERENCES Movies(movie_id) ON DELETE CASCADE
);

DROP PROCEDURE IF EXISTS sptopmovies;
DELIMITER //
CREATE PROCEDURE sptopmovies()
BEGIN
    SELECT m.movie_id, m.title, m.genre,
    AVG(r.rating) AS avg_rating
    FROM Movies m
    JOIN Ratings r ON m.movie_id = r.movie_id
    GROUP BY m.movie_id, m.title, m.genre
    ORDER BY avg_rating DESC;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sppopulargenres;
DELIMITER //
CREATE PROCEDURE sppopulargenres()
BEGIN
    SELECT genre, COUNT(*) AS total_movies
    FROM Movies
    GROUP BY genre
    ORDER BY total_movies DESC;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sptrending;
DELIMITER //
CREATE PROCEDURE sptrending()
BEGIN
    SELECT m.movie_id, m.title,
    COUNT(*) AS views
    FROM Watch_History w
    JOIN Movies m ON w.movie_id = m.movie_id
    WHERE w.watch_date >= CURDATE() - INTERVAL 7 DAY
    GROUP BY m.movie_id, m.title
    ORDER BY views DESC;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sprecommend;
DELIMITER //
CREATE PROCEDURE sprecommend(IN uid INT)
BEGIN
    SELECT DISTINCT m.movie_id, m.title
    FROM Ratings r1
    JOIN Ratings r2 ON r1.movie_id = r2.movie_id
    JOIN Movies m ON r2.movie_id = m.movie_id
    WHERE r1.user_id = uid
    AND r2.user_id != uid
    AND r2.movie_id NOT IN (
        SELECT movie_id FROM Ratings WHERE user_id = uid
    );
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS spuseractivity;
DELIMITER //
CREATE PROCEDURE spuseractivity()
BEGIN
    SELECT u.user_id, u.name,
    COUNT(w.movie_id) AS total_watched,
    MAX(w.watch_date) AS last_watch
    FROM Users u
    LEFT JOIN Watch_History w ON u.user_id = w.user_id
    GROUP BY u.user_id, u.name
    ORDER BY total_watched DESC;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS spadduser;
DELIMITER //
CREATE PROCEDURE spadduser(IN pname VARCHAR(100), IN page INT)
BEGIN
    INSERT INTO Users(name, age) VALUES(pname, page);
    SELECT LAST_INSERT_ID() AS user_id;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS spaddmovie;
DELIMITER //
CREATE PROCEDURE spaddmovie(IN ptitle VARCHAR(200), IN pgenre VARCHAR(100))
BEGIN
    INSERT INTO Movies(title, genre) VALUES(ptitle, pgenre);
    SELECT LAST_INSERT_ID() AS movie_id;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS spaddrating;
DELIMITER //
CREATE PROCEDURE spaddrating(IN puid INT, IN pmid INT, IN prating FLOAT)
BEGIN
    INSERT INTO Ratings(user_id, movie_id, rating)
    VALUES(puid, pmid, prating);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS spaddwatch;
DELIMITER //
CREATE PROCEDURE spaddwatch(IN puid INT, IN pmid INT, IN pdate DATE)
BEGIN
    INSERT INTO Watch_History(user_id, movie_id, watch_date)
    VALUES(puid, pmid, pdate);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS spgetmovies;
DELIMITER //
CREATE PROCEDURE spgetmovies()
BEGIN
    SELECT * FROM Movies ORDER BY movie_id;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS spgetusers;
DELIMITER //
CREATE PROCEDURE spgetusers()
BEGIN
    SELECT * FROM Users ORDER BY user_id;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS spgetratings;
DELIMITER //
CREATE PROCEDURE spgetratings()
BEGIN
    SELECT u.name, m.title, r.rating
    FROM Ratings r
    JOIN Users u ON r.user_id = u.user_id
    JOIN Movies m ON r.movie_id = m.movie_id;
END //
DELIMITER ;