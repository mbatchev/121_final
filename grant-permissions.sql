CREATE USER 'appadmin'@'localhost' IDENTIFIED BY 'adminpw';
CREATE USER 'appclient'@'localhost' IDENTIFIED BY 'clientpw';
-- Can add more users or refine permissions
GRANT ALL PRIVILEGES ON letterboxd.* TO 'appadmin'@'localhost';
GRANT SELECT ON letterboxd.* TO 'appclient'@'localhost';
GRANT INSERT ON letterboxd.* TO 'appclient'@'localhost';
GRANT UPDATE ON letterboxd.* TO 'appclient'@'localhost';
GRANT EXECUTE ON letterboxd.* TO 'appclient'@'localhost';
FLUSH PRIVILEGES;
