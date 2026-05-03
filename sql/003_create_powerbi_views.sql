CREATE OR REPLACE VIEW analytics.vw_listening_overview AS
SELECT
    COUNT(*) AS total_plays,
    COUNT(DISTINCT track_id) AS unique_tracks,
    COUNT(DISTINCT artist_id) AS unique_artists,
    ROUND(SUM(played_ms) / 60000.0, 2) AS total_minutes_listened,
    MIN(played_at) AS first_listening_date,
    MAX(played_at) AS last_listening_date
FROM analytics.fact_listening_history;

CREATE OR REPLACE VIEW analytics.vw_top_tracks AS
SELECT
    dt.track_name,
    dt.album_name,
    da.artist_name,
    COUNT(*) AS play_count,
    ROUND(SUM(f.played_ms) / 60000.0, 2) AS minutes_listened
FROM analytics.fact_listening_history f
LEFT JOIN analytics.dim_track dt
    ON f.track_id = dt.track_id
LEFT JOIN analytics.dim_artist da
    ON f.artist_id = da.artist_id
GROUP BY
    dt.track_name,
    dt.album_name,
    da.artist_name
ORDER BY play_count DESC;

CREATE OR REPLACE VIEW analytics.vw_top_artists AS
SELECT
    da.artist_name,
    COUNT(*) AS play_count,
    COUNT(DISTINCT f.track_id) AS unique_tracks,
    ROUND(SUM(f.played_ms) / 60000.0, 2) AS minutes_listened
FROM analytics.fact_listening_history f
LEFT JOIN analytics.dim_artist da
    ON f.artist_id = da.artist_id
GROUP BY da.artist_name
ORDER BY play_count DESC;

CREATE OR REPLACE VIEW analytics.vw_listening_by_day AS
SELECT
    played_at::date AS listening_date,
    COUNT(*) AS play_count,
    ROUND(SUM(played_ms) / 60000.0, 2) AS minutes_listened
FROM analytics.fact_listening_history
GROUP BY played_at::date
ORDER BY listening_date;

CREATE OR REPLACE VIEW analytics.vw_listening_by_hour AS
SELECT
    EXTRACT(HOUR FROM played_at)::int AS listening_hour,
    COUNT(*) AS play_count,
    ROUND(SUM(played_ms) / 60000.0, 2) AS minutes_listened
FROM analytics.fact_listening_history
GROUP BY EXTRACT(HOUR FROM played_at)::int
ORDER BY listening_hour;

CREATE OR REPLACE VIEW analytics.vw_listening_heatmap AS
SELECT
    EXTRACT(DOW FROM played_at)::int AS day_of_week,
    TO_CHAR(played_at, 'Day') AS day_name,
    EXTRACT(HOUR FROM played_at)::int AS listening_hour,
    COUNT(*) AS play_count,
    ROUND(SUM(played_ms) / 60000.0, 2) AS minutes_listened
FROM analytics.fact_listening_history
GROUP BY
    EXTRACT(DOW FROM played_at)::int,
    TO_CHAR(played_at, 'Day'),
    EXTRACT(HOUR FROM played_at)::int
ORDER BY day_of_week, listening_hour;
