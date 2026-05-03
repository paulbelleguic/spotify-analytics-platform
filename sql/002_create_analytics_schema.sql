CREATE TABLE IF NOT EXISTS analytics.dim_track AS
SELECT DISTINCT ON (track_id)
    track_id,
    track_name,
    album_id,
    album_name,
    duration_ms,
    popularity,
    explicit
FROM raw.spotify_recently_played
WHERE track_id IS NOT NULL
ORDER BY track_id, played_at DESC;

CREATE TABLE IF NOT EXISTS analytics.dim_artist AS
SELECT DISTINCT ON (artist_id)
    artist_id,
    artist_name
FROM raw.spotify_recently_played
WHERE artist_id IS NOT NULL
ORDER BY artist_id, played_at DESC;

CREATE TABLE IF NOT EXISTS analytics.dim_time AS
SELECT DISTINCT
    played_at,
    played_at::date AS listening_date,
    EXTRACT(YEAR FROM played_at)::int AS year,
    EXTRACT(MONTH FROM played_at)::int AS month,
    EXTRACT(DAY FROM played_at)::int AS day,
    EXTRACT(HOUR FROM played_at)::int AS hour,
    EXTRACT(DOW FROM played_at)::int AS day_of_week,
    TO_CHAR(played_at, 'Day') AS day_name,
    CASE
        WHEN EXTRACT(DOW FROM played_at) IN (0, 6) THEN TRUE
        ELSE FALSE
    END AS is_weekend
FROM raw.spotify_recently_played;

CREATE TABLE IF NOT EXISTS analytics.fact_listening_history AS
SELECT
    id AS listening_id,
    played_at,
    track_id,
    artist_id,
    duration_ms AS played_ms,
    'spotify_api_recently_played' AS source,
    ingested_at
FROM raw.spotify_recently_played;
