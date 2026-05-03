SELECT DISTINCT ON (track_id)
    track_id,
    track_name,
    album_id,
    album_cover_url,
    duration_ms,
    duration_minutes,
    popularity,
    explicit
FROM {{ ref('stg_listening_history') }}
WHERE track_id IS NOT NULL
ORDER BY track_id, played_at DESC
