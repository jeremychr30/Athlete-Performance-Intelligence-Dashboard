{{ config(materialized='table') }}

SELECT DISTINCT
    PI.player_sk,
    PI.player_id,
    P.team_sk,
    PI.position_sk,
    PI.player_name,
    PI.age,
    PI.age_group,
    PI.height_cm,
    PI.weight_kg,
    PI.bmi
FROM {{ ref('stg_players_info') }} PI
JOIN {{ ref('stg_player_match_stats') }} P ON P.player_id = PI.player_id
WHERE PI.player_id IS NOT NULL

