{{ config(materialized='view') }}

WITH source AS (
    SELECT *
    FROM {{ source('ProjetBasketFFS','raw_team_training_sessions')}}
),

players AS (
    SELECT
    player_sk,
    player_id

    FROM {{ref('stg_players_info')}}
),

exercise_types AS (
    SELECT
    exercise_type_sk,
    exercise_type
    FROM {{ ref('stg_exercise_type') }}
),

games AS (
    SELECT 
    game_sk,
    game_id,
    date_sk,
    parsed_game_date
    FROM {{ref('stg_games')}}
),

season_mapping AS (
    SELECT *
    FROM {{ref('stg_season_mapping')}}
),

training_cleaned AS (
    SELECT
    CAST(Session_ID AS STRING) AS session_id,
    CAST(Player_ID AS STRING) AS player_id,
    Player_Name AS player_name,
    DATE(Session_Date) AS session_date,
    DATE(Next_Match_Date) AS next_match_date,
    CAST(Days_Before_Match AS INT64) AS days_before_match,
    TRIM(Exercise_Type) AS exercise_type,
    CAST(duration_min AS FLOAT64) AS duration_min,
    CAST(Heart_Rate AS FLOAT64) AS heart_rate,
    CAST(Respiratory_Rate AS FLOAT64) AS respiratory_rate,
    CAST(Body_Temperature AS FLOAT64) AS body_temperature,
    CAST(Accel_X AS FLOAT64) AS accel_x,
    CAST(Accel_Y AS FLOAT64) AS accel_y,
    CAST(Accel_Z AS FLOAT64) AS accel_Z,
    CAST(Gyro_X AS FLOAT64) AS gyro_x,
    CAST(Gyro_Y AS FLOAT64) AS gyro_y,
    CAST(Gyro_Z AS FLOAT64) AS gyro_z,
    CAST(Steps AS INT64) AS steps,
    CAST(Strength_Score AS FLOAT64) AS strength_score,
    CAST(Agility_sec AS FLOAT64) AS agility_sec,
    CAST(Endurance_Score AS FLOAT64) AS endurance_score,
    CAST(Jump_Height_cm AS FLOAT64) AS jump_height_cm,
    CAST(`Shooting_Accuracy_%` AS FLOAT64) AS shooting_accuracy_pct,
    CAST(Dribbling_Speed_sec AS FLOAT64) AS dribbling_speed_sec,
    CAST(`Passing_Accuracy_%` AS FLOAT64) AS passing_accuracy_pct,
    CAST(Defense_Rating AS FLOAT64) AS defense_rating,
    CAST(Focus_Level AS FLOAT64) AS focus_level,
    CAST(Weekly_Training_Hours AS FLOAT64) AS weekly_training_hours,
    CAST(Load_Intensity_Score AS FLOAT64) AS intensity_score,
    CAST(Fatigue_Level AS STRING) AS fatigue_level,
    CAST(Injury_Risk AS FLOAT64) AS injury_risk,
    CAST(Recovery_Time_Hours AS FLOAT64) AS recovery_time_h,
    CAST(Performance_Score AS FLOAT64) AS performance_score,
    CASE
        WHEN LOWER(Injury_Risk_Level) = 'high'
        THEN 1 
        ELSE 0
        END AS high_injury_risk,
    (CASE
        WHEN LOWER(fatigue_Level) = 'low' THEN 20
        WHEN LOWER(fatigue_Level) = 'medium' THEN 60
        WHEN LOWER(fatigue_Level) = 'high' THEN 100
        END
        ) * 0.25 + (CAST(Load_Intensity_Score AS FLOAT64) * 10) * 0.25 
        + (CAST(Heart_Rate AS FLOAT64) / 200 * 100) * 0.10 
        + ((60 - CAST(Recovery_Time_Hours AS FLOAT64)) / 60 * 100) * 0.20  
        + ((CAST(Body_Temperature AS FLOAT64) - 36) / 3 * 100) * 0.10  
        + (CAST(Agility_sec AS FLOAT64) * 10) * 0.10
        AS injury_compil_score

FROM source)

SELECT 
    {{dbt_utils.generate_surrogate_key(['T.session_id'])}} AS training_session_sk,
    P.player_sk,
    G.game_sk AS next_game_sk,
    G.date_sk,
    E.exercise_type_sk,
    T.session_id,
    T.duration_min,
    T.heart_rate,
    T.respiratory_rate,
    T.body_temperature,
    T.accel_x,
    T.accel_y,
    T.accel_z,
    T.gyro_x,
    T.gyro_y,
    T.gyro_z,
    T.steps,
    T.strength_score,
    T.agility_sec,
    T.endurance_score,
    T.jump_height_cm,
    T.shooting_accuracy_pct,
    T.dribbling_speed_sec,
    T.passing_accuracy_pct,
    T.defense_rating,
    T.focus_level,
    T.weekly_training_hours,
    T.fatigue_level,
    T.injury_risk,
    T.recovery_time_h,
    T.performance_score,
    T.intensity_score,
    T.high_injury_risk,
    T.injury_compil_score

FROM training_cleaned T
LEFT JOIN players P ON t.player_id = P.player_id
LEFT JOIN exercise_types E ON UPPER(TRIM(T.exercise_type)) = UPPER(TRIM(E.exercise_type))
LEFT JOIN games G ON T.next_match_date = G.parsed_game_date