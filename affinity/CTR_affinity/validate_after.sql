-- Validate AFTER: CTR Affinity
WITH prob_check AS (
  SELECT ucid, SUM(ctr_prob) AS prob_sum
  FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step4_ctr_affinity_v2`
  GROUP BY ucid
)
SELECT COUNT(*) AS total_users,
  COUNTIF(ABS(prob_sum-1.0)>1e-4) AS prob_not_sum_to_1,
  ROUND(MIN(prob_sum),6) AS min_sum, ROUND(MAX(prob_sum),6) AS max_sum
FROM prob_check;
-- PASS: prob_not_sum_to_1=0, min=max=1.0
