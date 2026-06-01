{{ config(materialized='table') }}

SELECT DISTINCT
    position_sk,
    position_name
    position_group
FROM {{ ref('stg_positions') }}
WHERE position_name IS NOT NULL
