SELECT
    CONCAT('export_', id::text) AS listening_id,
    played_at,
    played_at::date AS listening_date,
    track_id,
    track_name,
    CASE
        WHEN artist_name IS NOT NULL THEN CONCAT('export_artist_', md5(artist_name))
        ELSE NULL
    END AS artist_id,
    artist_name,
    CASE
        WHEN album_name IS NOT NULL THEN CONCAT('export_album_', md5(COALESCE(artist_name, '') || '|' || album_name))
        ELSE NULL
    END AS album_id,
    album_name,
    NULL::text AS album_type,
    NULL::text AS album_release_date,
    NULL::text AS album_cover_url,
    ms_played AS duration_ms,
    ROUND(ms_played / 60000.0, 2) AS duration_minutes,
    NULL::integer AS popularity,
    NULL::boolean AS explicit,
    'spotify_extended_streaming_history' AS source,
    ingested_at
FROM raw.spotify_streaming_history_export
WHERE played_at IS NOT NULL
  AND track_name IS NOT NULL
  AND track_id IS NOT NULL
  AND ms_played IS NOT NULL
