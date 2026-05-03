{{ config(materialized='view', schema='analytics') }}

SELECT
    CASE
        WHEN t.explicit THEN 'Explicit'
        ELSE 'Non-Explicit'
    END AS explicit_category,
    COUNT(DISTINCT f.track_id) AS unique_tracks,
    COUNT(*) AS play_count,
    ROUND(SUM(f.played_ms) / 60000.0, 2) AS minutes_listened
FROM {{ ref('fact_listening_history') }} f
LEFT JOIN {{ ref('dim_tracks') }} t
    ON f.track_id = t.track_id
GROUP BY
    CASE
        WHEN t.explicit THEN 'Explicit'
        ELSE 'Non-Explicit'
    END
