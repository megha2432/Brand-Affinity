-- Validate AFTER: Final Unified
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(is_top_ctr_brand) AS top_ctr_count,
  COUNTIF(is_top_conv_brand) AS top_conv_count,
  COUNTIF(ctr_conv_aligned) AS aligned_count,
  COUNTIF(ctr_prob IS NULL AND conv_prob IS NULL) AS fully_orphaned
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step8_affinity_final_v2`;
-- PASS: fully_orphaned=0
-- Phase 2 actuals: aligned=1,478,081 (7% of rows)
