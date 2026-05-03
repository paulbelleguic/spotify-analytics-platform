CREATE OR REPLACE VIEW analytics.vw_listening_overview AS
SELECT
    COUNT(*) AS total_plays,
    COUNT(DISTINCT track_id) AS unique_tracks,
    COUNT(DISTINCT artist_id) AS unique_artists,
    COUNT(DISTINCT album_id) AS unique_albums,
    ROUND(SUM(played_ms) / 60000.0, 2) AS total_minutes_listened,
    ROUND(SUM(played_ms) / 3600000.0, 2) AS total_hours_listened,
    MIN(time_id) AS first_listening_time,
    MAX(time_id) AS last_listening_time
FROM analytics.fact_listening_history;

CREATE OR REPLACE VIEW analytics.vw_top_tracks AS
SELECT
    t.track_id,
    t.track_name,
    ar.artist_name,
    al.album_name,
    COUNT(*) AS play_count,
    ROUND(SUM(f.played_ms) / 60000.0, 2) AS minutes_listened
FROM analytics.fact_listening_history f
LEFT JOIN analytics.dim_tracks t
    ON f.track_id = t.track_id
LEFT JOIN analytics.dim_artists ar
    ON f.artist_id = ar.artist_id
LEFT JOIN analytics.dim_albums al
    ON f.album_id = al.album_id
GROUP BY
    t.track_id,
    t.track_name,
    ar.artist_name,
    al.album_name
ORDER BY play_count DESC;

CREATE OR REPLACE VIEW analytics.vw_top_artists AS
SELECT
    ar.artist_id,
    ar.artist_name,
    COUNT(*) AS play_count,
    COUNT(DISTINCT f.track_id) AS unique_tracks,
    COUNT(DISTINCT f.album_id) AS unique_albums,
    ROUND(SUM(f.played_ms) / 60000.0, 2) AS minutes_listened
FROM analytics.fact_listening_history f
LEFT JOIN analytics.dim_artists ar
    ON f.artist_id = ar.artist_id
GROUP BY
    ar.artist_id,
    ar.artist_name
ORDER BY play_count DESC;

CREATE OR REPLACE VIEW analytics.vw_listening_by_day AS
SELECT
    tm.listening_date,
    COUNT(*) AS play_count,
    COUNT(DISTINCT f.track_id) AS unique_tracks,
    ROUND(SUM(f.played_ms) / 60000.0, 2) AS minutes_listened
FROM analytics.fact_listening_history f
LEFT JOIN analytics.dim_time tm
    ON f.time_id = tm.time_id
GROUP BY tm.listening_date
ORDER BY tm.listening_date;

CREATE OR REPLACE VIEW analytics.vw_listening_by_hour AS
SELECT
    tm.hour AS listening_hour,
    COUNT(*) AS play_count,
    ROUND(SUM(f.played_ms) / 60000.0, 2) AS minutes_listened
FROM analytics.fact_listening_history f
LEFT JOIN analytics.dim_time tm
    ON f.time_id = tm.time_id
GROUP BY tm.hour
ORDER BY tm.hour;

CREATE OR REPLACE VIEW analytics.vw_listening_heatmap AS
SELECT
    tm.day_of_week,
    tm.day_name,
    tm.hour AS listening_hour,
    COUNT(*) AS play_count,
    ROUND(SUM(f.played_ms) / 60000.0, 2) AS minutes_listened
FROM analytics.fact_listening_history f
LEFT JOIN analytics.dim_time tm
    ON f.time_id = tm.time_id
GROUP BY
    tm.day_of_week,
    tm.day_name,
    tm.hour
ORDER BY
    tm.day_of_week,
    tm.hour;

CREATE OR REPLACE VIEW analytics.vw_listening_by_day_period AS
SELECT
    tm.day_period,
    COUNT(*) AS play_count,
    ROUND(SUM(f.played_ms) / 60000.0, 2) AS minutes_listened
FROM analytics.fact_listening_history f
LEFT JOIN analytics.dim_time tm
    ON f.time_id = tm.time_id
GROUP BY tm.day_period
ORDER BY
    CASE tm.day_period
        WHEN 'Morning' THEN 1
        WHEN 'Afternoon' THEN 2
        WHEN 'Evening' THEN 3
        WHEN 'Night' THEN 4
        ELSE 5
    END;
