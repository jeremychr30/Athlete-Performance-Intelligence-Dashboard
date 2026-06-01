{{ config(materialized='table') }}
WITH source AS (
    SELECT *
    FROM {{ ref('fct_team_matches') }}
)
SELECT
    TM.team_match_sk,
    TM.game_sk,
    TM.team_sk,
    TM.opponent_team_sk,
    TM.date_sk,
    D.full_date,
    G.season,
    T.team_name,
    OT.team_name AS opponent_team_name,
    TM.home_away,
    TM.win_flag,
    TM.pts,
    TM.fg_pct,
    TM.fg3_pct,
    TM.ft_pct,
    TM.reb,
    TM.ast,
    TM.stl,
    TM.blk,
    TM.turnovers,
    TM.plus_minus,
    CASE
        WHEN TM.plus_minus > 0 THEN 1
        ELSE 0
    END AS positive_impact_flag
FROM source TM
LEFT JOIN {{ ref('dim_teams') }} T ON TM.team_sk = T.team_sk

LEFT JOIN {{ ref('dim_teams') }} OT ON TM.opponent_team_sk = OT.team_sk

LEFT JOIN {{ ref('dim_dates') }} D ON TM.date_sk = D.date_sk

LEFT JOIN {{ ref('dim_games') }} G ON TM.game_sk = G.game_sk