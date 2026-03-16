-- Step 04: V5 Velocity Score

CREATE OR REPLACE TABLE
  `zeotap-dev-datascience.FEL_eu_west3.brand_step2_v5_velocity_v2`
AS
SELECT
  ucid, brand,
  SUM(IF(days_ago <= 15, intent_weight, 0))    AS recent_score,
  SUM(IF(days_ago BETWEEN 16 AND 30, intent_weight, 0)) AS older_score,
  COUNT(IF(days_ago <= 15, 1, NULL))            AS recent_events,
  COUNT(IF(days_ago BETWEEN 16 AND 30, 1, NULL)) AS older_events,
  LEAST(GREATEST(
    CASE
      WHEN SUM(IF(days_ago<=15, intent_weight,0)) > 0
       AND SUM(IF(days_ago BETWEEN 16 AND 30, intent_weight,0)) = 0
      THEN 2.0  -- new interest
      WHEN SUM(IF(days_ago<=15, intent_weight,0)) <= 0
       AND SUM(IF(days_ago BETWEEN 16 AND 30, intent_weight,0)) > 0
      THEN 0.1  -- fading
      WHEN SUM(IF(days_ago<=15, intent_weight,0)) <= 0
       AND SUM(IF(days_ago BETWEEN 16 AND 30, intent_weight,0)) = 0
      THEN 0.5  -- no signal
      ELSE COALESCE(SAFE_DIVIDE(
        SUM(IF(days_ago<=15, intent_weight,0)),
        SUM(IF(days_ago BETWEEN 16 AND 30, intent_weight,0))), 0.5)
    END, 0.1), 5.0) AS v5_score
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step0_train_v2`
GROUP BY ucid, brand;
