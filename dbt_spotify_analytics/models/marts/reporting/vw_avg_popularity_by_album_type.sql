{{ config(materialized='view', schema='analytics') }}

SELECT
    COALESCE(al.album_type, 'unknown') AS album_type,
    ROUND(AVG(t.popularity), 2) AS avg_popularity,
    COUNT(DISTINCT f.track_id) AS unique_tracks
FROM {{ ref('fact_listening_history') }} f
LEFT JOIN {{ ref('dim_tracks') }} t
    ON f.track_id = t.track_id
LEFT JOIN {{ ref('dim_albums') }} al
    ON f.album_id = al.album_id
WHERE t.popularity IS NOT NULL
GROUP BY COALESCE(al.album_type, 'unknown')
