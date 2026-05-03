DROP VIEW IF EXISTS analytics.vw_listening_overview CASCADE;
DROP VIEW IF EXISTS analytics.vw_top_tracks CASCADE;
DROP VIEW IF EXISTS analytics.vw_top_artists CASCADE;
DROP VIEW IF EXISTS analytics.vw_listening_by_day CASCADE;
DROP VIEW IF EXISTS analytics.vw_listening_by_hour CASCADE;
DROP VIEW IF EXISTS analytics.vw_listening_heatmap CASCADE;

DROP TABLE IF EXISTS analytics.fact_listening_history CASCADE;
DROP TABLE IF EXISTS analytics.dim_time CASCADE;
DROP TABLE IF EXISTS analytics.dim_albums CASCADE;
DROP TABLE IF EXISTS analytics.dim_artists CASCADE;
DROP TABLE IF EXISTS analytics.dim_tracks CASCADE;

CREATE TABLE analytics.dim_tracks AS
SELECT DISTINCT ON (track_id)
    track_id,
    track_name,
    album_id,
    duration_ms,
    popularity,
    explicit
FROM staging.stg_recently_played
WHERE track_id IS NOT NULL
ORDER BY track_id, played_at DESC;

ALTER TABLE analytics.dim_tracks ADD PRIMARY KEY (track_id);

CREATE TABLE analytics.dim_artists AS
SELECT DISTINCT ON (artist_id)
    artist_id,
    artist_name
FROM staging.stg_recently_played
WHERE artist_id IS NOT NULL
ORDER BY artist_id, played_at DESC;

ALTER TABLE analytics.dim_artists ADD PRIMARY KEY (artist_id);

CREATE TABLE analytics.dim_albums AS
SELECT DISTINCT ON (album_id)
    album_id,
    album_name,
    artist_id
FROM staging.stg_recently_played
WHERE album_id IS NOT NULL
ORDER BY album_id, played_at DESC;

ALTER TABLE analytics.dim_albums ADD PRIMARY KEY (album_id);

CREATE TABLE analytics.dim_time AS
SELECT DISTINCT
    played_at AS time_id,
    played_at::date AS listening_date,
    EXTRACT(YEAR FROM played_at)::int AS year,
    EXTRACT(QUARTER FROM played_at)::int AS quarter,
    EXTRACT(MONTH FROM played_at)::int AS month,
    TRIM(TO_CHAR(played_at, 'Month')) AS month_name,
    EXTRACT(WEEK FROM played_at)::int AS week,
    EXTRACT(DAY FROM played_at)::int AS day,
    EXTRACT(DOW FROM played_at)::int AS day_of_week,
    TRIM(TO_CHAR(played_at, 'Day')) AS day_name,
    EXTRACT(HOUR FROM played_at)::int AS hour,
    CASE
        WHEN EXTRACT(DOW FROM played_at)::int IN (0, 6) THEN TRUE
        ELSE FALSE
    END AS is_weekend,
    CASE
        WHEN EXTRACT(HOUR FROM played_at)::int BETWEEN 5 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM played_at)::int BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM played_at)::int BETWEEN 18 AND 22 THEN 'Evening'
        ELSE 'Night'
    END AS day_period
FROM staging.stg_recently_played
WHERE played_at IS NOT NULL;

ALTER TABLE analytics.dim_time ADD PRIMARY KEY (time_id);

CREATE TABLE analytics.fact_listening_history AS
SELECT
    raw_id AS listening_id,
    played_at AS time_id,
    track_id,
    artist_id,
    album_id,
    duration_ms AS played_ms,
    'spotify_api_recently_played' AS source,
    ingested_at
FROM staging.stg_recently_played;

ALTER TABLE analytics.fact_listening_history ADD PRIMARY KEY (listening_id);

ALTER TABLE analytics.fact_listening_history
ADD CONSTRAINT fk_fact_track
FOREIGN KEY (track_id) REFERENCES analytics.dim_tracks(track_id);

ALTER TABLE analytics.fact_listening_history
ADD CONSTRAINT fk_fact_artist
FOREIGN KEY (artist_id) REFERENCES analytics.dim_artists(artist_id);

ALTER TABLE analytics.fact_listening_history
ADD CONSTRAINT fk_fact_album
FOREIGN KEY (album_id) REFERENCES analytics.dim_albums(album_id);

ALTER TABLE analytics.fact_listening_history
ADD CONSTRAINT fk_fact_time
FOREIGN KEY (time_id) REFERENCES analytics.dim_time(time_id);
