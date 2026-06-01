{{ config(materialized='table') }}

SELECT DISTINCT
    game_sk,
    game_id,
    date_sk,
    season,
    matchup,
    home_away,
    wl,
    opponent_team_sk,
    opponent_team_name
FROM {{ ref('stg_games') }}
WHERE game_id IS NOT NULL