-- Step 03: V1 Recency Score
-- lambda = 0.015 (46 day half-life for brand loyalty)

CREATE OR REPLACE TABLE
  `zeotap-dev-datascience.FEL_eu_west3.brand_step1_v1_recency_v2`
AS
SELECT
  ucid, brand,
  GREATEST(SUM(intent_weight * EXP(-0.015 * days_ago)), 0) AS v1_score,
  GREATEST(SUM(discount_signal * EXP(-0.015 * days_ago)), 0) AS v1_discount_score,
  ROUND(AVG(discount_factor) * 100, 2)          AS avg_discount_pct,
  ROUND(SAFE_DIVIDE(COUNTIF(discount_factor > 0),
    COUNT(*)) * 100, 2)                          AS discount_interaction_pct,
  COUNT(*)                                       AS v1_event_count,
  MIN(days_ago)                                  AS most_recent_days_ago,
  MAX(days_ago)                                  AS oldest_event_days_ago
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step0_train_v2`
GROUP BY ucid, brand;
