{{ config(materialized='table') }}

SELECT DISTINCT
    exercise_type_sk,
    exercise_type,
    exercise_group
FROM {{ ref('stg_exercise_type') }}
WHERE exercise_type IS NOT NULL
