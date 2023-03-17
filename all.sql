drop database if exists letterboxd;
create database letterboxd;
use letterboxd;
source setup.sql;
source load-data.sql;
source setup-passwords.sql;
source setup-routines.sql;
source grant-permissions.sql;