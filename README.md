# sql_mini_project

# Movie Recommendation & Rating Analysis System

A simple web application to manage movie data, user ratings, and watch history. It also provides analytics like top-rated movies, popular genres, trending movies, and basic recommendations.

## Files

* `schema.sql` – database tables and stored procedures
* `app.py` – backend server (Flask)
* `templates/index.html` – frontend page,style

## How to Run

### 1. Setup Database

Open MySQL and run:

```
mysql -u root -p < schema.sql
```

### 2. Set Your MySQL Password

Update in `app.py`:

```
'password': 'YOUR_PASSWORD'
```

### 3. Install Dependencies

```
pip install flask mysql-connector-python
```

### 4. Start Server

```
python app.py
```

Then open:
http://localhost:5000

## Features

* Add and view users, movies, ratings, and watch history
* Top-rated movies based on average ratings
* Most popular genres
* Trending movies based on recent activity
* Basic movie recommendations based on user similarity
* User activity analysis
