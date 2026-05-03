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
    payload #>> '{track,album,album_type}' AS album_type,
    payload #>> '{track,album,release_date}' AS album_release_date,
    payload #>> '{track,album,images,0,url}' AS album_cover_url,
    duration_ms,
    ROUND(duration_ms / 60000.0, 2) AS duration_minutes,
    popularity,
    explicit,
    ingested_at
FROM raw.spotify_recently_played
WHERE track_id IS NOT NULL
  AND played_at IS NOT NULL
