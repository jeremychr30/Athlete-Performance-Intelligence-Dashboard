{{ config(materialized='table') }}

WITH source AS (
    SELECT *
    FROM {{ ref('stg_player_match_stats') }}
)

SELECT
    player_match_sk,
    player_sk,
    game_sk,
    position_sk,
    team_sk,
    minutes_played,
    pts,
    reb,
    ast,
    stl,
    blk,
    turnovers,
    fgm,
    fga,
    fg_pct,
    fg3m,
    fg3a,
    fg3_pct,
    ftm,
    fta,
    ft_pct,
    plus_minus,
    efficiency_score,
    efficiency_per_36,
    did_not_play
FROM source