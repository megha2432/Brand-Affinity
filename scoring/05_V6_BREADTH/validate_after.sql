-- Validate AFTER: V6 Breadth
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(v6_score <= 0) AS zero_scores,
  COUNTIF(n_unique_products < 1) AS zero_products,
  ROUND(MAX(v6_score), 4) AS max_score,
  ROUND(AVG(n_unique_products), 2) AS avg_products,
  ROUND(AVG(avg_intent_depth), 4) AS avg_depth
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step3_v6_breadth_v2`;
-- PASS: zero_scores=0, zero_products=0
-- Phase 2 actuals: avg_products=1.68, max_products=199, avg_depth=0.1236
