
-- ═══════════════════════════════════════════════════════════
-- Shared validation queries for all brand affinity steps
-- ═══════════════════════════════════════════════════════════

-- V1 Recency: no negative scores, no duplicates
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(v1_score < 0) AS negative_scores,
  MAX(v1_event_count) AS max_event_count,
  COUNT(DISTINCT CONCAT(ucid,'|',brand)) AS distinct_pairs
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step1_v1_recency_v2`;
-- PASS: negative_scores=0, max_event_count<=1000

-- V5 Velocity: all scores in [0.1, 5.0]
SELECT
  COUNTIF(v5_score < 0.1) AS below_min,
  COUNTIF(v5_score > 5.0) AS above_max,
  COUNTIF(v5_score = 2.0) AS new_interest,
  COUNTIF(v5_score = 0.1) AS fading_interest
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step2_v5_velocity_v2`;
-- PASS: below_min=0, above_max=0

-- CTR Affinity: probabilities sum to 1.0 per user
WITH prob_check AS (
  SELECT ucid, SUM(ctr_prob) AS prob_sum
  FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step4_ctr_affinity_v2`
  GROUP BY ucid
)
SELECT
  COUNTIF(ABS(prob_sum - 1.0) > 1e-4) AS prob_not_sum_to_1,
  ROUND(MIN(prob_sum), 6) AS min_sum,
  ROUND(MAX(prob_sum), 6) AS max_sum
FROM prob_check;
-- PASS: prob_not_sum_to_1=0

-- Final accuracy check
WITH actuals AS (
  SELECT ucid,
    ARRAY_AGG(brand ORDER BY cnt DESC LIMIT 1)[OFFSET(0)] AS actual
  FROM (
    SELECT ucid, brand, COUNT(*) AS cnt
    FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step0_holdout_v2`
    GROUP BY ucid, brand
  )
  GROUP BY ucid
)
SELECT
  COUNT(*) AS users_validated,
  ROUND(SAFE_DIVIDE(
    COUNTIF(s.top_conv_brand = a.actual),
    COUNT(*)) * 100, 2) AS conv_accuracy_pct
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step9_user_summary_v2` s
JOIN actuals a USING (ucid);
-- TARGET: >= 80.82% (Phase 2 baseline)
