SELECT
    CONCAT('api_', raw_id::text) AS listening_id,
    played_at,
    listening_date,
    track_id,
    track_name,
    artist_id,
    artist_name,
    album_id,
    album_name,
    album_type,
    album_release_date,
    album_cover_url,
    duration_ms,
    duration_minutes,
    popularity,
    explicit,
    'spotify_api_recently_played' AS source,
    ingested_at
FROM {{ ref('stg_recently_played') }}

UNION ALL

SELECT
    listening_id,
    played_at,
    listening_date,
    track_id,
    track_name,
    artist_id,
    artist_name,
    album_id,
    album_name,
    album_type,
    album_release_date,
    album_cover_url,
    duration_ms,
    duration_minutes,
    popularity,
    explicit,
    source,
    ingested_at
FROM {{ ref('stg_streaming_history_export') }}
