from flask import Flask, request, jsonify, render_template
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Athi@2005',
    'database': 'movie_db'
}

def get_connection():
    try:
        return mysql.connector.connect(**DB_CONFIG)
    except Error as e:
        print("Database Error:", e)
        return None

def call_proc(proc_name, args=()):
    conn = get_connection()

    if conn is None:
        return []

    cursor = conn.cursor(dictionary=True)

    try:
        cursor.callproc(proc_name, args)
        results = []
        for result in cursor.stored_results():
            results = result.fetchall()
        conn.commit()
        return results
    except Error as e:
        print("Procedure Error:", e)
        return []
    finally:
        cursor.close()
        conn.close()


@app.route('/')
def index():
    return render_template('ui.html')


@app.route('/api/top-movies')
def top_movies():
    data = call_proc('sptopmovies')
    return jsonify(data)

@app.route('/api/popular-genres')
def popular_genres():
    data = call_proc('sppopulargenres')
    return jsonify(data)

@app.route('/api/trending')
def trending():
    data = call_proc('sptrending')
    return jsonify(data)

@app.route('/api/recommend/<int:uid>')
def recommend(uid):
    data = call_proc('sprecommend', (uid,))
    return jsonify(data)

@app.route('/api/user-activity')
def user_activity():
    data = call_proc('spuseractivity')
    return jsonify(data)


@app.route('/api/movies')
def get_movies():
    data = call_proc('spgetmovies')
    return jsonify(data)

@app.route('/api/users')
def get_users():
    data = call_proc('spgetusers')
    return jsonify(data)

@app.route('/api/ratings')
def get_ratings():
    data = call_proc('spgetratings')
    return jsonify(data)



@app.route('/api/add-user', methods=['POST'])
def add_user():
    d = request.json
    if not d or 'name' not in d or 'age' not in d:
        return jsonify({'error': 'Invalid input. name and age are required.'}), 400
    result = call_proc('spadduser', (d['name'], int(d['age'])))
    user_id = result[0]['user_id'] if result and len(result) > 0 else None
    return jsonify({'success': True, 'user_id': user_id})

@app.route('/api/add-movie', methods=['POST'])
def add_movie():
    d = request.json
    if not d or 'title' not in d or 'genre' not in d:
        return jsonify({'error': 'Invalid input. title and genre are required.'}), 400
    result = call_proc('spaddmovie', (d['title'], d['genre']))
    movie_id = result[0]['movie_id'] if result and len(result) > 0 else None
    return jsonify({'success': True, 'movie_id': movie_id})

@app.route('/api/add-rating', methods=['POST'])
def add_rating():
    d = request.json
    if not d or 'user_id' not in d or 'movie_id' not in d or 'rating' not in d:
        return jsonify({'error': 'Invalid input. user_id, movie_id and rating are required.'}), 400
    call_proc('spaddrating', (int(d['user_id']), int(d['movie_id']), float(d['rating'])))
    return jsonify({'success': True})

@app.route('/api/add-watch', methods=['POST'])
def add_watch():
    d = request.json
    if not d or 'user_id' not in d or 'movie_id' not in d or 'watch_date' not in d:
        return jsonify({'error': 'Invalid input. user_id, movie_id and watch_date are required.'}), 400
    from datetime import datetime
    try:
        datetime.strptime(d['watch_date'], '%Y-%m-%d')
    except ValueError:
        return jsonify({'error': 'Invalid date format. Use YYYY-MM-DD.'}), 400
    call_proc('spaddwatch', (int(d['user_id']), int(d['movie_id']), d['watch_date']))
    return jsonify({'success': True})
@app.route('/api/delete-movie/<int:mid>', methods=['DELETE'])
def delete_movie(mid):
    conn = get_connection()
    if conn is None:
        return jsonify({'error': 'DB connection failed'}), 500
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM Movies WHERE movie_id = %s", (mid,))
        conn.commit()
        return jsonify({'success': True})
    except Error as e:
        return jsonify({'error': str(e)}), 400
    finally:
        cursor.close()
        conn.close()

@app.route('/api/delete-user/<int:uid>', methods=['DELETE'])
def delete_user(uid):
    conn = get_connection()
    if conn is None:
        return jsonify({'error': 'DB connection failed'}), 500
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM Users WHERE user_id = %s", (uid,))
        conn.commit()
        return jsonify({'success': True})
    except Error as e:
        return jsonify({'error': str(e)}), 400
    finally:
        cursor.close()
        conn.close()

@app.route('/api/delete-rating/<int:uid>/<int:mid>', methods=['DELETE'])
def delete_rating(uid, mid):
    conn = get_connection()
    if conn is None:
        return jsonify({'error': 'DB connection failed'}), 500
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM Ratings WHERE user_id = %s AND movie_id = %s", (uid, mid))
        conn.commit()
        return jsonify({'success': True})
    except Error as e:
        return jsonify({'error': str(e)}), 400
    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    app.run(debug=False)