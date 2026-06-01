{{ config(materialized='view') }}

WITH main_team AS (
    SELECT DISTINCT
        CAST(TEAM_ID AS STRING) AS team_id,
        TRIM(TEAM_NAME) AS team_name,
        TRIM(TEAM_ABBREVIATION) AS team_abbreviation,
        TRIM(TEAM_CITY) AS team_city
    FROM {{ source('ProjetBasketFFS', 'raw_team_boxscores') }}
),

opponents AS (
    SELECT DISTINCT
        CAST(NULL AS STRING) AS team_id,
        CASE
            WHEN MATCHUP LIKE '%vs.%'
            THEN TRIM(SPLIT(MATCHUP, 'vs.')[OFFSET(1)])
            WHEN MATCHUP LIKE '%@%'
            THEN TRIM(SPLIT(MATCHUP, '@')[OFFSET(1)])
            ELSE NULL
        END AS team_name,
        CAST(NULL AS STRING) AS team_abbreviation,
        CAST(NULL AS STRING) AS team_city
    FROM {{ source('ProjetBasketFFS', 'raw_team_games_dataset') }}
),

all_teams AS (
    SELECT * FROM main_team
    UNION DISTINCT
    SELECT * FROM opponents
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['team_name']) }} AS team_sk,
    CAST(Team_ID AS STRING) AS team_id,
    team_name,
    team_abbreviation,
    team_city
FROM all_teams