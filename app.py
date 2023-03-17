import sys  # to print error messages to sys.stderr
import mysql.connector
# To get error codes from the connector, useful for user-friendly
# error-handling
import mysql.connector.errorcode as errorcode

# Debugging flag to print errors when debugging that shouldn't be visible
# to an actual client. Set to False when done testing.
DEBUG = True


# ----------------------------------------------------------------------
# SQL Utility Functions
# ----------------------------------------------------------------------
def get_conn():
    """"
    Returns a connected MySQL connector instance, if connection is successful.
    If unsuccessful, exits.
    """
    try:
        conn = mysql.connector.connect(
          host='localhost',
          user='appclient',
          # Find port in MAMP or MySQL Workbench GUI or with
          # SHOW VARIABLES WHERE variable_name LIKE 'port';
          port='3306',
          password='clientpw',
          database='letterboxd',
          autocommit = True
        )
        return conn
    except mysql.connector.Error as err:
        # Remember that this is specific to _database_ users, not
        # application users. So is probably irrelevant to a client in your
        # simulated program. Their user information would be in a users table
        # specific to your database.
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR and DEBUG:
            sys.stderr.write('Incorrect username or password when connecting to DB.')
        elif err.errno == errorcode.ER_BAD_DB_ERROR and DEBUG:
            sys.stderr.write('Database does not exist.')
        elif DEBUG:
            sys.stderr.write(err)
        else:
            sys.stderr.write('An error occurred, please contact the administrator.')
        sys.exit(1)

def get_admin():
    """"
    Returns a connected MySQL connector instance, if connection is successful.
    If unsuccessful, exits.
    Connected to admin account
    """
    try:
        conn = mysql.connector.connect(
          host='localhost',
          user='appadmin',
          # Find port in MAMP or MySQL Workbench GUI or with
          # SHOW VARIABLES WHERE variable_name LIKE 'port';
          port='3306',
          password='adminpw',
          database='letterboxd',
          autocommit = True
        )
        return conn
    except mysql.connector.Error as err:
        # Remember that this is specific to _database_ users, not
        # application users. So is probably irrelevant to a client in your
        # simulated program. Their user information would be in a users table
        # specific to your database.
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR and DEBUG:
            sys.stderr.write('Incorrect username or password when connecting to DB.')
        elif err.errno == errorcode.ER_BAD_DB_ERROR and DEBUG:
            sys.stderr.write('Database does not exist.')
        elif DEBUG:
            sys.stderr.write(err)
        else:
            sys.stderr.write('An error occurred, please contact the administrator.')
        sys.exit(1)


## MAIN MENU
def show_options(logged_in, is_admin):
    """
    Displays options users can choose in the application
    """
    print('What would you like to do? ')
    if logged_in:
        if is_admin:
            print('\u001b[35m  (a) - view all posts\u001b[0m')
            print('\u001b[35m  (d) - delete a post\u001b[0m')
        print('  (f) - view feed')
        print('  (l) - like post')
        print('  (st) - search for movie/show')
        print('  (p) - post a review')
        print('  (x) - log out')
    else:
        print('  (l) - login')
        print('  (s) - sign up')
    print('  (q) - quit')
    print()
    while True:
        ans = input('Enter an option: ')
        if ans:
            ans = ans.lower()
        if logged_in:
            if ans == "q":
                return "exit"
            elif ans == "x":
                return "log_out"
            elif ans == "f":
                return "feed"
            elif ans == "l":
                return "like"
            elif ans == "st":
                return "search_title"
            elif ans == "p":
                return "post"
            elif ans == "a" and is_admin:
                return "all"
            elif ans == "d" and is_admin:
                return "del"
            else:
                print('Unknown option.')
        else:
            if ans == "q":
                return "exit"
            elif ans == "l":
                return "login"
            elif ans == "s":
                return "signup"
            else:
                print('Unknown option.')


def quit_ui():
    """
    Quits the program, printing a good bye message to the user.
    """
    print('Good bye!')
    exit()


## QUERIES AND MENU OPTIONS
def login():
    """
    prompts the user for their username and password, then attempts to log them in
    function returns the logged in status as a boolean and the uid or None if unsuccesful
    """
    u = input("enter your username: ")
    p = input("enter your password: ")
    try:
        conn.reconnect()
        cursor = conn.cursor()
        cursor.execute("SELECT log_in('%s', '%s')" % (u, p))
        rows = cursor.fetchall()
        if rows and rows[0]:
            if rows[0][0] == 0:
                print("\u001b[31mIncorrect username or password. Try again.\u001b[0m")
                return False, None
            else:
                print("\033[1;32mSuccesfully logged in. \u001b[0m")
                return True, rows[0][0]
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred when logging in.')
        print("Something went wrong, try again.")
        return False, None  
        
    if not rows:
        print('No results found.')

def signup():
    """
    Signs the user up with a given username and password.
    If the username is taken, the request fails and the user is notified.
    If it is succesful, their status is changed to signed in, and their 
    username and password are stored in the database;
    """
    u = input("enter a username to use: ")
    p = input("enter a password to use: ")
    try:
        conn.reconnect()
        cursor = conn.cursor()
        cursor.execute("CALL sp_sign_up('%s', '%s')" % (u, p))
        rows = cursor.fetchall()
        if rows and rows[0]:
            if rows[0][0] == 0:
                print("\u001b[31mThis username is taken. Try again.\u001b[0m")
                return False, None
            else:
                print("\033[1;32mSuccesfully signed up. \u001b[0m")
                return True, int(rows[0][0])
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred when signing up.')
        return False, None  

def get_feed(uid):
    """
    Gets and prints all reviews and associated information posted by you or your friends
    """
    try:
        conn.reconnect()
        cursor = conn.cursor()
        cursor.execute(
                """SELECT username, 
                    review_content, 
                    star_rating, 
                    post_time, 
                    rid, 
                    primaryTitle, 
                    COUNT(likes.uid) as likes
                    FROM reviews as r
                    JOIN users USING(uid)
                    JOIN titles USING(imdb_id)
                    LEFT JOIN likes USING(rid)
                    WHERE (r.uid = %d) 
                        OR (SELECT COUNT(*) FROM friendships
                            WHERE uid_1 = %d AND uid_2 = r.uid) != 0
                    GROUP BY rid
                    ORDER BY post_time DESC;""" % (uid, uid))
        rows = cursor.fetchall()
        print("")
        for row in rows:
            username = row[0]
            txt = row[1]
            stars = row[2]
            posted = str(row[3])
            rid = row[4]
            movieName = row[5]
            likes = row[6]
            print("\u001b[34m%s posted on %s \u001b[0m" % (username, posted))
            print("They reviewed \u001b[34m'%s'\u001b[0m" % movieName)
            print("-------------------------------------")
            print(txt)
            print("-------------------------------------")
            print("They gave a %d / 5 rating" % (stars))
            print("review id: %d" % (rid))
            print("%d likes" % (likes))
            print("")
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred when fetching your feed.')

def like(uid):
    """
    Lets the user like a post given its review ID which they can find in their feed
    """
    rid = input("Enter the review id of the review you want to like (it can be found on your feed): ")
    try:
        conn.reconnect()
        cursor = conn.cursor()
        cursor.execute("CALL sp_like_post('%s', '%s')" % (uid, rid))
        rows = cursor.fetchall()
        if rows and rows[0]:
            if rows[0][0] == 0:
                print("\u001b[31mThat review ID was not found. Try again.\u001b[0m")
                return
            else:
                print("\033[1;32mSuccesfully liked post. \u001b[0m")
                return
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred when signing up.')
        return

def search_titles():
    """
    asks the user for a term to search for,
    then returns 25 movies or TV shows that match their search term.
    This includes the imdb_id, which they can then use to leave a review
    """
    search = input("enter a term to search for: ")
    try:
        conn.reconnect()
        cursor = conn.cursor()
        cursor.execute(
                """SELECT imdb_id, primaryTitle, releaseYear, runtimeMinutes, titleType
                    FROM titles 
                    WHERE primaryTitle LIKE "%s%%" -- placeholder search term
                    AND (titleType = "tvSeries" OR titleType = "movie") LIMIT 25;""" % (search))
        rows = cursor.fetchall()
        for row in rows:
            movieID = row[0]
            title = row[1]
            release = row[2]
            runtime = row[3]
            typ = row[4]
            print("\u001b[34m%s \u001b[0m" % title)
            if release is not None:
                print("released %d" % (release))
            if runtime is not None:
                print("runtime %d minutes" % (runtime))
            if typ is not None:
                print("type: %s" % (typ))
            print("unique id:\u001b[34m %s \u001b[0m" % (movieID))
            print("-----------")
            print("")
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred when fetching your feed.')
        return False, None

def post_review(uid):
    """
    Lets the user 
    """
    imdb_id = input("Enter the movie id of the title you want to review (it can be found by searching using (st)): ")
    text = input("Enter the text for your review: ")
    stars = input("Enter the star rating 1 - 5: ")
    if not stars.isdigit() or int(stars) < 1 or int(stars) > 5:
        print("Invalid star rating. Must be integer between 1 and 5")
    try:
        conn.reconnect()
        cursor = conn.cursor()
        cursor.execute("CALL sp_create_post('%s', '%s', '%s', %d)" % (uid, imdb_id, text, int(stars)))
        rows = cursor.fetchall()
        if rows and rows[0]:
            if rows[0][0] == 0:
                print("\u001b[31mThat movie ID was not found. Try again.\u001b[0m")
                return
            else:
                print("\033[1;32mSuccesfully posted review. Find it in your feed. \u001b[0m")
                return
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred when signing up.')
        return

## ADMIN MENU OPTIONS AND QUERIES
def isadmin(uid):
    """
    after logging in, checks if the user is an admin to give them appropriate options
    returns true if admin in order to serve the proper options
    and also reassigns the connector to be an admin connector in order to enable 
    elevated priviledge operations
    """
    global conn
    try:
        conn.reconnect()
        cursor = conn.cursor()
        cursor.execute("SELECT is_admin FROM users WHERE uid = %d; " % (uid))
        rows = cursor.fetchall()
        if rows and rows[0] and rows[0][0] == 1:
            print("\u001b[35mWelcome to the admin portal!\u001b[0m")
            conn = get_admin()
            return True 
        else:
            conn = get_conn()
        return False

    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred when logging in.')
        print("Something went wrong, try again.")
        return False

def get_all_posts():
    """
    For admin users:
    gets all the recent posts to allow moderation
    """
    try:
        conn.reconnect()
        cursor = conn.cursor()
        cursor.execute(
                """SELECT username, 
                    review_content, 
                    star_rating, 
                    post_time, 
                    rid, 
                    primaryTitle, 
                    COUNT(likes.uid) as likes
                    FROM reviews as r
                    JOIN users USING(uid)
                    JOIN titles USING(imdb_id)
                    LEFT JOIN likes USING(rid)
                    GROUP BY rid
                    ORDER BY post_time DESC;""")
        rows = cursor.fetchall()
        print("")
        for row in rows:
            username = row[0]
            txt = row[1]
            stars = row[2]
            posted = str(row[3])
            rid = row[4]
            movieName = row[5]
            likes = row[6]
            print("\u001b[34m%s posted on %s \u001b[0m" % (username, posted))
            print("They reviewed \u001b[34m'%s'\u001b[0m" % movieName)
            print("-------------------------------------")
            print(txt)
            print("-------------------------------------")
            print("They gave a %d / 5 rating" % (stars))
            print("review id: %d" % (rid))
            print("%d likes" % (likes))
            print("")
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred when fetching all posts.')

def delete_post():
    """
    For admins:
    marks a post for deletion, which then gets deleted by a trigger
    """
    rid = input("Enter the review id of the review you want to delete: ")
    try:
        conn.reconnect()
        cursor = conn.cursor()
        cursor.execute("CALL sp_delete_post('%s')" % (rid))
        rows = cursor.fetchall()
        if rows and rows[0]:
            if rows[0][0] == 0:
                print("\u001b[31mThat review ID was not found. Try again.\u001b[0m")
                return
            else:
                print("\033[1;32mSuccesfully deleted post. \u001b[0m")
                return
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred when signing up.')
        return

## MAIN LOOP
def main():
    """
    Main function for starting things up.
    """
    logged = False
    uid = None 
    admin = False
    while True:
        match show_options(logged, admin):
            case "exit":
                quit_ui()
            case "log_out":
                logged = False 
                uid = None
            case "login":
                logged, uid = login()
                if uid is not None:
                    admin = isadmin(uid)
            case "signup":
                logged, uid = signup()
            case "feed":
                get_feed(uid)
            case "like":
                like(uid)
            case "search_title":
                search_titles()
            case "post":
                post_review(uid)
            case "all":
                get_all_posts()
            case "del":
                delete_post()
                

if __name__ == '__main__':
    # This conn is a global object that other functinos can access.
    # You'll need to use cursor = conn.cursor() each time you are
    # about to execute a query with cursor.execute(<sqlquery>)
    conn = get_conn()
    main()
