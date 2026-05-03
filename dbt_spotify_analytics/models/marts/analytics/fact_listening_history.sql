SELECT
    listening_id,
    played_at AS time_id,
    track_id,
    artist_id,
    album_id,
    duration_ms AS played_ms,
    source,
    ingested_at
FROM {{ ref('stg_listening_history') }}
