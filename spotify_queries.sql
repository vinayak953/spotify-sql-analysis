-- 1. Find all the distinct album names
SELECT DISTINCT album_name
FROM Tracks;

-- 2. Who is the artist of song 'Never Seen the Rain'?
SELECT artist_name
FROM Tracks
WHERE track_name = 'Never Seen the Rain';

-- 3. Name all the users & email who have registered with gmail id
SELECT username, email
FROM Users
WHERE email LIKE '%@gmail.com';

-- 4. List the name of users along with registration dates,
-- who have registered after April-22

SELECT username, registration_date
FROM Users
WHERE registration_date > '2022-04-30';

-- 5. Extract the track names, artists, albums and release dates
-- for tracks released in year 2017

SELECT track_name, artist_name, album_name, release_date
FROM Tracks
WHERE YEAR(release_date) = 2017;

-- 6. Find details of users who registered between May and August

SELECT *
FROM Users
WHERE MONTH(registration_date) BETWEEN 5 AND 8;

-- 7. Count number of playlists created by each user

SELECT user_id, COUNT(playlist_id) AS total_playlists
FROM Playlists
GROUP BY user_id;

-- 8. Find track names and durations for a specific album

SELECT track_name, duration
FROM Tracks
WHERE album_name = '÷ (Divide)';

-- 9. Calculate average duration of tracks

SELECT AVG(duration) AS average_duration
FROM Tracks;

-- 10. How many users registered with yahoo.com id?

SELECT COUNT(*) AS yahoo_users
FROM Users
WHERE email LIKE '%@yahoo.com';


-- 1. Find the playlist names and the number of tracks in each playlist
-- created by users whose email addresses end with '@gmail.com'

SELECT p.playlist_name,
       COUNT(pt.track_id) AS total_tracks
FROM Users u
JOIN Playlists p
ON u.user_id = p.user_id
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
WHERE u.email LIKE '%@gmail.com'
GROUP BY p.playlist_name;


-- 2. Retrieve usernames and email addresses of users
-- who created playlists with more than 5 tracks
-- and average track duration > 200 seconds

SELECT u.username, u.email
FROM Users u
JOIN Playlists p
ON u.user_id = p.user_id
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
JOIN Tracks t
ON pt.track_id = t.track_id
GROUP BY u.user_id, u.username, u.email, p.playlist_id
HAVING COUNT(pt.track_id) > 5
AND AVG(t.duration) > 200;


-- 3. Find track and artist names of tracks
-- having duration greater than average duration

SELECT track_name, artist_name
FROM Tracks
WHERE duration >
(
   SELECT AVG(duration)
   FROM Tracks
);


-- 4. Find users who created playlists with tracks
-- from albums released in 2019

SELECT DISTINCT u.username
FROM Users u
JOIN Playlists p
ON u.user_id = p.user_id
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
JOIN Tracks t
ON pt.track_id = t.track_id
WHERE YEAR(t.release_date) = 2019;


-- 5. Playlist names and total durations
-- sorted by number of tracks descending

SELECT p.playlist_name,
       SUM(t.duration) AS total_duration,
       COUNT(pt.track_id) AS total_tracks
FROM Playlists p
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
JOIN Tracks t
ON pt.track_id = t.track_id
GROUP BY p.playlist_name
ORDER BY total_tracks DESC;


-- 6. Find playlists having tracks
-- longer than average track duration

SELECT DISTINCT p.playlist_name
FROM Playlists p
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
JOIN Tracks t
ON pt.track_id = t.track_id
WHERE t.duration >
(
   SELECT AVG(duration)
   FROM Tracks
);


-- 7. Top 3 playlists with most tracks

SELECT p.playlist_name,
       COUNT(pt.track_id) AS total_tracks
FROM Playlists p
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
GROUP BY p.playlist_name
ORDER BY total_tracks DESC
LIMIT 3;


-- 8. Average track duration for each user
-- in descending order

SELECT u.username,
       AVG(t.duration) AS avg_duration
FROM Users u
JOIN Playlists p
ON u.user_id = p.user_id
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
JOIN Tracks t
ON pt.track_id = t.track_id
GROUP BY u.username
ORDER BY avg_duration DESC;


-- 9. Find track and artist names
-- included in at least two playlists

SELECT t.track_name,
       t.artist_name
FROM Tracks t
JOIN PlaylistTracks pt
ON t.track_id = pt.track_id
GROUP BY t.track_id, t.track_name, t.artist_name
HAVING COUNT(DISTINCT pt.playlist_id) >= 2;


-- 10. Playlist names and total durations
-- created by users registered in 2022

SELECT p.playlist_name,
       SUM(t.duration) AS total_duration
FROM Users u
JOIN Playlists p
ON u.user_id = p.user_id
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
JOIN Tracks t
ON pt.track_id = t.track_id
WHERE YEAR(u.registration_date) = 2022
GROUP BY p.playlist_name;

-- 1. Find track and artist names included in playlists
-- created by users registered before average registration date

SELECT DISTINCT t.track_name, t.artist_name
FROM Tracks t
JOIN PlaylistTracks pt
ON t.track_id = pt.track_id
JOIN Playlists p
ON pt.playlist_id = p.playlist_id
JOIN Users u
ON p.user_id = u.user_id
WHERE u.registration_date <
(
    SELECT AVG(registration_date)
    FROM Users
);


-- 2. Users who created playlists containing tracks from
-- both 'After Hours' and
-- 'When We All Fall Asleep, Where Do We Go?'

SELECT DISTINCT u.username
FROM Users u
JOIN Playlists p
ON u.user_id = p.user_id
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
JOIN Tracks t
ON pt.track_id = t.track_id
WHERE p.playlist_id IN
(
    SELECT pt1.playlist_id
    FROM PlaylistTracks pt1
    JOIN Tracks t1
    ON pt1.track_id = t1.track_id
    WHERE t1.album_name = 'After Hours'
)
AND p.playlist_id IN
(
    SELECT pt2.playlist_id
    FROM PlaylistTracks pt2
    JOIN Tracks t2
    ON pt2.track_id = t2.track_id
    WHERE t2.album_name = 'When We All Fall Asleep, Where Do We Go?'
);


-- 3. Top 3 users with highest average track duration

SELECT u.username,
       AVG(t.duration) AS avg_duration
FROM Users u
JOIN Playlists p
ON u.user_id = p.user_id
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
JOIN Tracks t
ON pt.track_id = t.track_id
GROUP BY u.username
ORDER BY avg_duration DESC
LIMIT 3;


-- 4. Tracks with duration greater than average duration
-- ranked within their albums

SELECT track_name,
       album_name,
       duration,
       RANK() OVER
       (
           PARTITION BY album_name
           ORDER BY duration DESC
       ) AS track_rank
FROM Tracks
WHERE duration >
(
    SELECT AVG(duration)
    FROM Tracks
);


-- 5. Playlist names, total tracks and playlist rank

SELECT p.playlist_name,
       COUNT(pt.track_id) AS total_tracks,
       RANK() OVER
       (
           ORDER BY COUNT(pt.track_id) DESC
       ) AS playlist_rank
FROM Playlists p
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
GROUP BY p.playlist_name;


-- 6. Users who created playlists with highest number
-- of tracks from Ed Sheeran

SELECT u.username,
       COUNT(t.track_id) AS total_tracks
FROM Users u
JOIN Playlists p
ON u.user_id = p.user_id
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
JOIN Tracks t
ON pt.track_id = t.track_id
WHERE t.artist_name = 'Ed Sheeran'
GROUP BY u.username
ORDER BY total_tracks DESC;


-- 7. Top users with highest number of unique tracks
-- from The Weeknd

SELECT u.username,
       COUNT(DISTINCT t.track_id) AS unique_tracks
FROM Users u
JOIN Playlists p
ON u.user_id = p.user_id
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
JOIN Tracks t
ON pt.track_id = t.track_id
WHERE t.artist_name LIKE '%The Weeknd%'
GROUP BY u.username
ORDER BY unique_tracks DESC;


-- 8. Tracks with duration greater than average duration
-- in their respective albums

SELECT track_name,
       album_name,
       duration
FROM Tracks t1
WHERE duration >
(
    SELECT AVG(duration)
    FROM Tracks t2
    WHERE t1.album_name = t2.album_name
);


-- 9. Playlist names with user names,
-- sorted by track count descending and username ascending

SELECT p.playlist_name,
       u.username,
       COUNT(pt.track_id) AS total_tracks
FROM Playlists p
JOIN Users u
ON p.user_id = u.user_id
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
GROUP BY p.playlist_name, u.username
ORDER BY total_tracks DESC, u.username ASC;


-- 10. Playlists with user names and position
-- of longest duration track in each playlist

SELECT p.playlist_name,
       u.username,
       pt.position,
       t.track_name,
       t.duration
FROM Playlists p
JOIN Users u
ON p.user_id = u.user_id
JOIN PlaylistTracks pt
ON p.playlist_id = pt.playlist_id
JOIN Tracks t
ON pt.track_id = t.track_id
WHERE t.duration =
(
    SELECT MAX(t2.duration)
    FROM PlaylistTracks pt2
    JOIN Tracks t2
    ON pt2.track_id = t2.track_id
    WHERE pt2.playlist_id = p.playlist_id
);













