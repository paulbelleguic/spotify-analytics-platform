{{ config(materialized='view', schema='analytics') }}

SELECT
    COUNT(*) AS total_plays,
    COUNT(DISTINCT track_id) AS unique_tracks,
    COUNT(DISTINCT artist_id) AS unique_artists,
    COUNT(DISTINCT album_id) AS unique_albums,
    ROUND(SUM(played_ms) / 60000.0, 2) AS total_minutes_listened,
    ROUND(SUM(played_ms) / 3600000.0, 2) AS total_hours_listened,
    MIN(time_id) AS first_listening_time,
    MAX(time_id) AS last_listening_time
FROM {{ ref('fact_listening_history') }}
