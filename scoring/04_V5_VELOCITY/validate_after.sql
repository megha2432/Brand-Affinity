-- Validate AFTER: V5 Velocity
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(v5_score < 0.1) AS below_min,
  COUNTIF(v5_score > 5.0) AS above_max,
  COUNTIF(v5_score = 2.0) AS new_interest,
  COUNTIF(v5_score = 0.1) AS fading_interest,
  COUNTIF(v5_score = 0.5) AS no_signal,
  ROUND(AVG(v5_score), 4) AS avg_score
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step2_v5_velocity_v2`;
-- PASS: below_min=0, above_max=0
-- Phase 2 actuals: new_interest=9.97M (48%), fading=1.32M (6%)
