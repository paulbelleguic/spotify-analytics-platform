SELECT DISTINCT ON (album_id)
    album_id,
    album_name,
    artist_id,
    album_type,
    album_release_date,
    album_cover_url
FROM {{ ref('stg_listening_history') }}
WHERE album_id IS NOT NULL
ORDER BY album_id, played_at DESC
