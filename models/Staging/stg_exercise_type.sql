{{ config(materialized='view') }}  --créé une vue pour mobiliser moins de ressources, pas besoin de table ici

WITH source AS (
    SELECT distinct exercise_type
    FROM {{source('ProjetBasketFFS', 'raw_team_training_sessions')}}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['Exercise_Type']) }} AS exercise_type_sk, --créé une clé simplifiée
    TRIM(exercise_type) AS exercise_type, --élimine les potentiels espaces avant ou après la chaine de caractères
    CASE --catégorise le type d'exo en 5 groupes distincts
        WHEN LOWER(exercise_type) LIKE '%shoot%'
        OR LOWER(exercise_type) LIKE '%free throw%' 
        THEN 'SHOOTING'
        WHEN LOWER(exercise_type) LIKE '%scrimmage%'
        OR LOWER(exercise_type) LIKE '%defense%'
        THEN 'TACTICAL'
        WHEN LOWER(exercise_type) LIKE '%skills%'
        THEN 'TECHNICAL'
        WHEN LOWER(exercise_type) LIKE '%strength%'
        OR LOWER(exercise_type) LIKE '%agility%'
        OR LOWER(exercise_type) LIKE '%cardio%'
        THEN 'PHYSICAL'
        ELSE 'OTHER'
    END AS exercise_group
FROM source