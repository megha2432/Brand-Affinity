-- Validate AFTER: Conv Affinity
SELECT
  COUNT(*) AS total_rows, COUNT(DISTINCT ucid) AS distinct_users,
  COUNTIF(conv_prob < 0) AS negative_prob,
  COUNTIF(v3_norm < 0 OR v3_norm > 1) AS v3_out_of_range,
  COUNTIF(v3_score = 0.0) AS non_purchasers,
  COUNTIF(v3_score > 0.0) AS purchasers
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step7_conv_affinity_v2`;
-- PASS: negative_prob=0, v3_out_of_range=0
-- Phase 2 actuals: non_purchasers=19.9M (96%), purchasers=815K (4%)
