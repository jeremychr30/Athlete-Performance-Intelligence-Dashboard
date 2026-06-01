{{ config(materialized='view') }}  --créé une vue pour mobiliser moins de ressources, pas besoin de table ici

WITH source AS (
    SELECT distinct position
    FROM {{source('ProjetBasketFFS', 'raw_team_players_personal_info')}}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['position']) }} AS position_sk, --créé une clé simplifiée
    UPPER(TRIM(POSITION)) AS position_name, --met en maj + élimine les potentiels espaces avant ou après la chaine de caractères
    CASE --simplifie et catégorise les postes comprenant guard et center, sinon alors wing
        WHEN UPPER(position) LIKE '%GUARD%' THEN 'BACKCOURT'
        WHEN UPPER(position) LIKE '%CENTER%' THEN 'FRONTCOURT'
        ELSE 'WING'
    END AS position_group
FROM source