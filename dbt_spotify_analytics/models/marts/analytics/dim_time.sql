SELECT DISTINCT
    played_at AS time_id,
    listening_date,
    EXTRACT(YEAR FROM played_at)::int AS year,
    EXTRACT(QUARTER FROM played_at)::int AS quarter,
    EXTRACT(MONTH FROM played_at)::int AS month,
    TRIM(TO_CHAR(played_at, 'Month')) AS month_name,
    EXTRACT(WEEK FROM played_at)::int AS week,
    EXTRACT(DAY FROM played_at)::int AS day,
    EXTRACT(DOW FROM played_at)::int AS day_of_week,
    TRIM(TO_CHAR(played_at, 'Day')) AS day_name,
    EXTRACT(HOUR FROM played_at)::int AS hour,
    CASE
        WHEN EXTRACT(DOW FROM played_at)::int IN (0, 6) THEN TRUE
        ELSE FALSE
    END AS is_weekend,
    CASE
        WHEN EXTRACT(HOUR FROM played_at)::int BETWEEN 5 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM played_at)::int BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM played_at)::int BETWEEN 18 AND 22 THEN 'Evening'
        ELSE 'Night'
    END AS day_period
FROM {{ ref('stg_listening_history') }}
WHERE played_at IS NOT NULL
