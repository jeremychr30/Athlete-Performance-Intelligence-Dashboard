{{ config(materialized='view') }}

WITH source AS (
    SELECT *
    FROM {{ source('ProjetBasketFFS', 'raw_team_boxscores') }}

),

games AS (
    SELECT
        game_sk,
        game_id,
        date_sk,
        opponent_team_sk,
        home_away
    FROM {{ ref('stg_games') }}

),

teams AS (
    SELECT
        team_sk,
        CAST(team_id AS STRING) AS team_id
    FROM {{ ref('stg_teams') }}

),

team_matches_cleaned AS (
    SELECT
        CAST(TEAM_ID AS STRING) AS team_id,
        CAST(GAME_ID AS STRING) AS game_id,
        CAST(PTS AS INT64) AS pts,
        CAST(FG_PCT AS FLOAT64) AS fg_pct,
        CAST(FG3_PCT AS FLOAT64) AS fg3_pct,
        CAST(FT_PCT AS FLOAT64) AS ft_pct,
        CAST(REB AS INT64) AS reb,
        CAST(AST AS INT64) AS ast,
        CAST(STL AS INT64) AS stl,
        CAST(BLK AS INT64) AS blk,
        CAST(`TO` AS INT64) AS turnovers,
        CAST(PLUS_MINUS AS FLOAT64) AS plus_minus,
        CASE
            WHEN CAST(PLUS_MINUS AS FLOAT64) > 0 THEN 1
            ELSE 0
        END AS win_flag
    FROM source
)

SELECT

    {{ dbt_utils.generate_surrogate_key(['C.team_id','C.game_id']) }} AS team_match_sk,
    G.game_sk,
    T.team_sk,
    G.opponent_team_sk,
    G.date_sk,
    G.home_away,
    C.win_flag,
    C.pts,
    C.fg_pct,
    C.fg3_pct,
    C.ft_pct,
    C.reb,
    C.ast,
    C.stl,
    C.blk,
    C.turnovers,
    C.plus_minus
FROM team_matches_cleaned C
LEFT JOIN games G ON TRIM(C.game_id) = TRIM(G.game_id)
LEFT JOIN teams T ON TRIM(C.team_id) = TRIM(T.team_id)