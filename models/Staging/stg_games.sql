{{ config(materialized='view') }} --créé une vue pour mobiliser moins de ressources, pas besoin de table ici

WITH source AS (
    SELECT *
    FROM {{ source('ProjetBasketFFS', 'raw_team_games_dataset') }}
),

--parcellise la date pour la normaliser entre les tables team_games_dataset et team_boxscores
parsed_games AS (
    SELECT
        Game_ID,
        PARSE_DATE('%b %d, %Y', GAME_DATE) AS parsed_game_date,
        MATCHUP,
        WL,
        CASE --catégorise les matches entre domicile si vs et extérieur si @ = at
            WHEN MATCHUP LIKE '%vs.%'
            THEN 'HOME'
            WHEN MATCHUP LIKE '%@%'
            THEN 'AWAY'
            ELSE 'UNKNOWN'
        END AS home_away,
        CASE --définit les adversaires via le matchup
            WHEN MATCHUP LIKE '%vs.%'
            THEN TRIM(SPLIT(MATCHUP, 'vs.')[OFFSET(1)])
            WHEN MATCHUP LIKE '%@%'
            THEN TRIM(SPLIT(MATCHUP, '@')[OFFSET(1)])
            ELSE NULL
        END AS opponent_team_name
    FROM source
),

teams AS (
    SELECT
        team_sk,
        team_name
    FROM {{ ref('stg_teams') }}
),

season_mapping AS (
    SELECT *
    FROM {{ ref('stg_season_mapping') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['P.Game_ID']) }} AS game_sk,
    T.team_sk AS opponent_team_sk,
    {{ dbt_utils.generate_surrogate_key(['CAST(P.parsed_game_date AS STRING)']) }} AS date_sk,
    CAST(P.Game_ID AS STRING) AS game_id,
    S.Season AS season,
    TRIM(P.MATCHUP) AS matchup,
    P.home_away,
    TRIM(P.WL) AS wl,
    P.opponent_team_name,
    P.parsed_game_date
FROM parsed_games P
LEFT JOIN teams T ON UPPER(TRIM(P.opponent_team_name)) = UPPER(TRIM(T.team_name))
LEFT JOIN season_mapping S ON P.parsed_game_date = S.match_date