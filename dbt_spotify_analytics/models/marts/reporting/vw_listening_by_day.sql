{{ config(materialized='view', schema='analytics') }}

SELECT
    tm.listening_date,
    COUNT(*) AS play_count,
    COUNT(DISTINCT f.track_id) AS unique_tracks,
    ROUND(SUM(f.played_ms) / 60000.0, 2) AS minutes_listened
FROM {{ ref('fact_listening_history') }} f
LEFT JOIN {{ ref('dim_time') }} tm
    ON f.time_id = tm.time_id
GROUP BY tm.listening_date
