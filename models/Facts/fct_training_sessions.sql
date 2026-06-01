{{ config(materialized='table') }}

SELECT
    training_session_sk, -- Surrogate key
    player_sk,
    next_game_sk,
    date_sk,
    exercise_type_sk, -- Foreign keys
    duration_min,
    heart_rate,
    respiratory_rate,
    body_temperature,
    steps,
    accel_x,
    accel_y,
    accel_z,
    gyro_x,
    gyro_y,
    gyro_z,  -- Mesures métier
    strength_score,
    agility_sec,
    endurance_score,
    jump_height_cm,   
    shooting_accuracy_pct,
    dribbling_speed_sec,
    passing_accuracy_pct,
    defense_rating,  -- Performance
    weekly_training_hours,
    intensity_score,
    fatigue_level,  -- Charge physique
    injury_risk, -- Risque
    high_injury_risk,
    injury_compil_score, 
    performance_score --KPI calculé

FROM {{ ref('stg_training_sessions') }}