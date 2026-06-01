{{ config(materialized='view') }}  --créé une vue pour mobiliser moins de ressources, pas besoin de table ici
WITH source AS (
    SELECT *
    FROM {{source('ProjetBasketFFS', 'raw_team_players_personal_info')}}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['PLAYER_ID']) }} AS player_sk, --créé une clé simplifiée
    CAST(PLAYER_ID AS string) AS player_id, --modifie le type de données
    {{ dbt_utils.generate_surrogate_key(['POSITION']) }} AS position_sk, --créé une clé simplifiée
    CAST(POSITION AS string) AS position,
    TRIM(PLAYER_NAME) AS player_name, --élimine les potentiels espaces avant ou après la chaine de caractères
    CAST(AGE AS int64) AS age,
    CASE --créé une catégorisation selon l'âge
        WHEN age <= 24 THEN 'ROOKIE'
        WHEN age BETWEEN 25 AND 31 THEN 'PRIME'
        else 'VETERAN'
    end AS age_group,
    CAST(HEIGHT_CM AS float64) AS height_cm, --modifie le type de données
    CAST(WEIGHT_KG AS float64) AS weight_kg, --modifie le type de données
    round(WEIGHT_KG / power(HEIGHT_CM / 100, 2),2) AS bmi --calcul de l'indice IMC
FROM source