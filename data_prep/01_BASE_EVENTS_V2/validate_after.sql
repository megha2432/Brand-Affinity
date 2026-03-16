-- Validate AFTER: 01 Base Events
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT ucid) AS distinct_users,
  COUNT(DISTINCT brand) AS distinct_brands,
  COUNTIF(intent_weight IS NULL) AS null_intent,
  COUNTIF(discount_factor < 0 OR discount_factor > 1) AS invalid_discount,
  COUNTIF(intent_weight > intent_weight_base) AS discount_not_reducing,
  ROUND(AVG(discount_factor)*100, 2) AS avg_discount_pct,
  ROUND(AVG(intent_weight), 4) AS avg_adj_intent,
  ROUND(AVG(intent_weight_base), 4) AS avg_base_intent
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step0_train_v2`;
-- PASS: null_intent=0, invalid_discount=0, discount_not_reducing=0
-- Phase 2 actuals: avg_base=0.1821, avg_adj=0.1244, reduction=31.7%
