{{ config(materialized='view') }}
SELECT DISTINCT --permet de récupérer la saison, table intermédiaire
    CAST(next_match_date AS DATE) AS match_date,
    Season
FROM {{ source('ProjetBasketFFS', 'raw_team_training_sessions') }}
WHERE next_match_date IS NOT NULL
AND Season IS NOT NULL