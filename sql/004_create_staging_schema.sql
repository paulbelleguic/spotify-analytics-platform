CREATE SCHEMA IF NOT EXISTS staging;

DROP VIEW IF EXISTS staging.stg_recently_played;

CREATE VIEW staging.stg_recently_played AS
SELECT
    id AS raw_id,
    played_at,
    played_at::date AS listening_date,
    track_id,
    track_name,
    artist_id,
    artist_name,
    album_id,
    album_name,
    duration_ms,
    popularity,
    explicit,
    ingested_at
FROM raw.spotify_recently_played
WHERE track_id IS NOT NULL
  AND played_at IS NOT NULL;
