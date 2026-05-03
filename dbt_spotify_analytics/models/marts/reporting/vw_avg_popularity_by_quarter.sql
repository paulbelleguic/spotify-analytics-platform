{{ config(materialized='view', schema='analytics') }}

SELECT
    EXTRACT(YEAR FROM tm.listening_date)::int AS year,
    EXTRACT(QUARTER FROM tm.listening_date)::int AS quarter,
    CONCAT(
        EXTRACT(YEAR FROM tm.listening_date)::int,
        '-Q',
        EXTRACT(QUARTER FROM tm.listening_date)::int
    ) AS year_quarter,
    ROUND(AVG(t.popularity), 2) AS avg_popularity,
    COUNT(DISTINCT f.track_id) AS unique_tracks,
    COUNT(*) AS play_count
FROM {{ ref('fact_listening_history') }} f
LEFT JOIN {{ ref('dim_time') }} tm
    ON f.time_id = tm.time_id
LEFT JOIN {{ ref('dim_tracks') }} t
    ON f.track_id = t.track_id
WHERE t.popularity IS NOT NULL
GROUP BY
    EXTRACT(YEAR FROM tm.listening_date)::int,
    EXTRACT(QUARTER FROM tm.listening_date)::int
