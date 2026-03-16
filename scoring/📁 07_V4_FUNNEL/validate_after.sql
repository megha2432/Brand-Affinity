-- Validate AFTER: V4 Funnel
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(max_funnel_stage < 1) AS below_min_stage,
  COUNTIF(max_funnel_stage > 5) AS above_max_stage,
  COUNTIF(v4_score < 1.1) AS below_min_score,
  COUNTIF(max_funnel_stage=2) AS stage_2,
  COUNTIF(max_funnel_stage=3) AS stage_3,
  COUNTIF(max_funnel_stage=4) AS stage_4,
  COUNTIF(max_funnel_stage=5) AS stage_5
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step6_v4_funnel_v2`;
-- PASS: below_min_stage=0, above_max_stage=0, below_min_score=0
