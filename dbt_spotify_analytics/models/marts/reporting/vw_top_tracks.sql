{{ config(materialized='view', schema='analytics') }}

SELECT
    t.track_id,
    t.track_name,
    ar.artist_name,
    al.album_name,
    al.album_type,
    al.album_release_date,
    t.album_cover_url,
    t.duration_minutes,
    t.popularity,
    t.explicit,
    COUNT(DISTINCT t.track_id) AS unique_tracks,
    COUNT(*) AS play_count,
    ROUND(SUM(f.played_ms) / 60000.0, 2) AS minutes_listened
FROM {{ ref('fact_listening_history') }} f
LEFT JOIN {{ ref('dim_tracks') }} t
    ON f.track_id = t.track_id
LEFT JOIN {{ ref('dim_artists') }} ar
    ON f.artist_id = ar.artist_id
LEFT JOIN {{ ref('dim_albums') }} al
    ON f.album_id = al.album_id
GROUP BY
    t.track_id,
    t.track_name,
    ar.artist_name,
    al.album_name,
    al.album_type,
    al.album_release_date,
    t.album_cover_url,
    t.duration_minutes,
    t.popularity,
    t.explicit
