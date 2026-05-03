{{ config(materialized='view', schema='analytics') }}

SELECT
    ar.artist_id,
    ar.artist_name,
    COUNT(*) AS play_count,
    COUNT(DISTINCT f.track_id) AS unique_tracks,
    COUNT(DISTINCT f.album_id) AS unique_albums,
    ROUND(SUM(f.played_ms) / 60000.0, 2) AS minutes_listened
FROM {{ ref('fact_listening_history') }} f
LEFT JOIN {{ ref('dim_artists') }} ar
    ON f.artist_id = ar.artist_id
GROUP BY
    ar.artist_id,
    ar.artist_name
