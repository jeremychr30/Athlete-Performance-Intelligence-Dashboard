{{ config(materialized='view') }}

WITH dates AS (
    SELECT DISTINCT
        PARSE_DATE('%b %d, %Y', game_date) AS full_date
    FROM {{ source('ProjetBasketFFS', 'raw_team_games_dataset') }}
    UNION DISTINCT
    SELECT DISTINCT
        CAST(session_date AS DATE) AS full_date
    FROM {{ source('ProjetBasketFFS', 'raw_team_training_sessions') }}

)

SELECT
    {{ dbt_utils.generate_surrogate_key(['full_date']) }} AS date_sk,
    full_date,
    EXTRACT(YEAR FROM full_date) AS year,
    EXTRACT(QUARTER FROM full_date) AS quarter,
    EXTRACT(MONTH FROM full_date) AS month,
    FORMAT_DATE('%B', full_date) AS month_name,
    EXTRACT(WEEK FROM full_date) AS week_number,
    EXTRACT(DAY FROM full_date) AS day,
    FORMAT_DATE('%A', full_date) AS weekday

FROM dates
WHERE full_date IS NOT NULL