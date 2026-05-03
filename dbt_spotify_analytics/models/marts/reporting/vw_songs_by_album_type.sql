{{ config(materialized='view', schema='analytics') }}

SELECT
    COALESCE(al.album_type, 'unknown') AS album_type,
    COUNT(DISTINCT f.track_id) AS unique_tracks,
    COUNT(*) AS play_count,
    ROUND(SUM(f.played_ms) / 60000.0, 2) AS minutes_listened
FROM {{ ref('fact_listening_history') }} f
LEFT JOIN {{ ref('dim_albums') }} al
    ON f.album_id = al.album_id
GROUP BY COALESCE(al.album_type, 'unknown')
