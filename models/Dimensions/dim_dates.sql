{{ config(materialized='table') }}

SELECT DISTINCT
    date_sk,
    full_date,
    year,
    quarter,
    month,
    month_name,
    week_number,
    day,
    weekday
    
FROM {{ ref('stg_dates') }}
WHERE full_date IS NOT NULL
ORDER BY full_date