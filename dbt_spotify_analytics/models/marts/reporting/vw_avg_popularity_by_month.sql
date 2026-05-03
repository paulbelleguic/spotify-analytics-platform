{{ config(materialized='view', schema='analytics') }}

SELECT
    DATE_TRUNC('month', tm.listening_date)::date AS listening_month,
    EXTRACT(YEAR FROM tm.listening_date)::int AS year,
    EXTRACT(MONTH FROM tm.listening_date)::int AS month,
    TRIM(TO_CHAR(tm.listening_date, 'Month')) AS month_name,
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
    DATE_TRUNC('month', tm.listening_date)::date,
    EXTRACT(YEAR FROM tm.listening_date)::int,
    EXTRACT(MONTH FROM tm.listening_date)::int,
    TRIM(TO_CHAR(tm.listening_date, 'Month'))
