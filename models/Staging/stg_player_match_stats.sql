{{ config(materialized='view') }} --créé une vue pour mobiliser moins de ressources, pas besoin de table ici
WITH SOURCE AS (
    SELECT *
    FROM {{ source('ProjetBasketFFS', 'raw_team_players_stats') }}
),

PLAYERS AS (
    SELECT
        PLAYER_ID,
        POSITION
    FROM {{ ref('stg_players_info') }}
),

JOINED AS (
    SELECT
        S.*,
        P.position
    FROM SOURCE S
    LEFT JOIN PLAYERS P ON CAST(S.PLAYER_ID AS STRING) = CAST(P.PLAYER_ID AS STRING)
),

CLEANED AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['PLAYER_ID', 'GAME_ID']) }} AS player_match_sk, --créé une clé simplifiée

        {{ dbt_utils.generate_surrogate_key(['PLAYER_ID']) }} AS player_sk,

        {{ dbt_utils.generate_surrogate_key(['GAME_ID']) }} AS game_sk,

        {{ dbt_utils.generate_surrogate_key(['TEAM_ID']) }} AS team_sk,

        {{ dbt_utils.generate_surrogate_key(['position']) }} AS position_sk,
        
        CAST(position as string) as position,
        CAST(PLAYER_ID AS STRING) AS player_id, --modifie le type de données
        CAST(GAME_ID AS STRING) AS game_id,
        CAST(TEAM_ID AS STRING) AS team_id,
        UPPER(TRIM(position)) AS position_name, 
        ROUND((SAFE_CAST(SPLIT(MIN, ':')[OFFSET(0)] AS FLOAT64)+(SAFE_CAST(SPLIT(MIN, ':')[OFFSET(1)] AS FLOAT64)/ 60)),2) AS minutes_played,
        --uniformise en minutes avec split à gauche [0] et split à droite [1] par rapport au : 
        CAST(PTS AS INT64) AS pts,

        CAST(REB AS INT64) AS reb,

        CAST(AST AS INT64) AS ast,

        CAST(STL AS INT64) AS stl,

        CAST(BLK AS INT64) AS blk,

        CAST(OREB AS INT64) AS oreb,

        CAST(DREB AS INT64) AS dreb,

        CAST(`TO` AS INT64) AS turnovers,

        CAST(FGM AS INT64) AS fgm,

        CAST(FGA AS INT64) AS fga,

        CAST(FG_PCT AS FLOAT64) AS fg_pct,

        CAST(FG3M AS INT64) AS fg3m,

        CAST(FG3A AS INT64) AS fg3a,

        CAST(FG3_PCT AS FLOAT64) AS fg3_pct,

        CAST(FTM AS INT64) AS ftm,

        CAST(FTA AS INT64) AS fta,

        CAST(FT_PCT AS FLOAT64) AS ft_pct,

        CAST(PLUS_MINUS AS FLOAT64) AS plus_minus,

        CASE --s'il y a un commentaire alors le joueur ne joue et cela créé un booléen analysable
            WHEN COMMENT IS NOT NULL THEN TRUE 
            ELSE FALSE
        END AS did_not_play

    FROM JOINED)

SELECT
-- calcule l'indicateur des stats positives - ballons perdus par rapport aux minutes jouées et rapportées sur un temps de 36 min (stat utilisée aux US pour référence)
-- le nullif permet d'éviter les divisions par 0 si le joueur n'a pas joué
    *,
    ROUND(((PTS + REB + AST + STL + BLK - TURNOVERS) / NULLIF(minutes_played, 0)) * 36,2) AS efficiency_per_36,
    CASE --ajoute une pondération sur les stats selon le poste 
        WHEN position = 'GUARD' THEN

            ROUND(((PTS + (2 * AST) + (1.5 * STL) + (1.5 * FG3M) - (2 * TURNOVERS))/NULLIF(MINUTES_PLAYED, 0)) * 36,2)

        WHEN position = 'FORWARD' THEN

            ROUND((((1.5 * PTS) + (1.5 * REB) + STL + AST + BLK - (1.5 * TURNOVERS)) / NULLIF(MINUTES_PLAYED, 0)) * 36,2)

        WHEN position = 'CENTER' THEN

            ROUND((((1.5 * PTS) + (2 * REB) + (2 * BLK) + (1.5 * OREB) - TURNOVERS)/NULLIF(MINUTES_PLAYED, 0)) * 36,2)

        WHEN position IN ('GUARD-FORWARD', 'FORWARD-GUARD') THEN

            ROUND((((PTS + (2 * AST) + (1.5 * STL) + (1.5 * FG3M) - (2 * TURNOVERS)) +((1.5 * PTS) + (1.5 * REB) + STL + AST + BLK - (1.5 * TURNOVERS))) / 2/NULLIF(MINUTES_PLAYED, 0)) * 36,2)

        WHEN position IN ('FORWARD-CENTER', 'CENTER-FORWARD') THEN

            ROUND(((((1.5 * PTS) + (1.5 * REB) + STL + AST + BLK - (1.5 * TURNOVERS)) + ((1.5 * PTS) + (2 * REB) + (2 * BLK) + (1.5 * OREB) - TURNOVERS)) / 2 / NULLIF(MINUTES_PLAYED, 0)) * 36,2)

        ELSE NULL

    END AS efficiency_score
FROM CLEANED