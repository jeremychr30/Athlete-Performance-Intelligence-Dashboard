{{ config(materialized='table') }}

SELECT DISTINCT
    team_sk,
    team_id,
    team_name,
    team_abbreviation,
    team_city

FROM {{ ref('stg_teams') }}

WHERE team_name IS NOT NULL