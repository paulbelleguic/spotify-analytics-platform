SELECT DISTINCT ON (artist_id)
    artist_id,
    artist_name
FROM {{ ref('stg_listening_history') }}
WHERE artist_id IS NOT NULL
ORDER BY artist_id, played_at DESC
