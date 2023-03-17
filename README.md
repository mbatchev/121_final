**To enable infile import:**

mysql> SET GLOBAL local_infile=1;
mysql> quit
/usr/local/mysql/bin/mysql -uroot -p --local-infile
SET GLOBAL log_bin_trust_function_creators = 1;
https://stackoverflow.com/questions/59993844/error-loading-local-data-is-disabled-this-must-be-enabled-on-both-the-client

**To set up database:**

create a database called "letterboxd";
make sure that "out.csv" is in the same directory
source setup.sql;
source load-data.sql;
source setup-passwords.sql;
source setup-routines.sql;
(alternately use __'source all.sql'__ to run all of those commands with one command)

**To use python file:**

"python3 app.py"
1. enter 'l' to login
2. login using one of credentials in setup-password. 
   An example admin user: username= "u1" password = "password"
   An example non-admin user: username = "u2" pasword = "123456"
3. alternately create new user
3. after logging in, can explore menu. Example: press 'f' to view your friends' posts.
   can also log back out and log in with another account or create another account.
4. enter "st" to search for a movie or TV show you know by prefix. Suggest testing "breaking" 
   and then "breaking bad" to see how it works.
5. Get the movie ID after finding the movie/show you want in the search results.
6. enter "p" to create a review on that movie using its ID.
7. Post will show up in your feed and feed of your friends


**Data source:**
https://datasets.imdbws.com/ "title.basics.tsv.gz"
documented here: https://www.imdb.com/interfaces/ 