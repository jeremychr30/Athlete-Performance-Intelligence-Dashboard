{{ config(materialized='table') }}

WITH source AS (
    SELECT *
    FROM {{ ref('stg_team_matches') }}
)

SELECT
    team_match_sk,
    game_sk,
    team_sk,
    opponent_team_sk,
    date_sk,
    home_away,
    win_flag,
    pts,
    fg_pct,
    fg3_pct,
    ft_pct,
    reb,
    ast,
    stl,
    blk,
    turnovers,
    plus_minus
FROM source