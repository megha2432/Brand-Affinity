-- Step 10: Final Unified Table
CREATE OR REPLACE TABLE
  `zeotap-dev-datascience.FEL_eu_west3.brand_step8_affinity_final_v2`
AS
SELECT
  COALESCE(c.ucid,v.ucid) AS ucid,
  COALESCE(c.brand,v.brand) AS brand,
  c.v1_score, c.v5_score, c.v6_score,
  c.v1_norm, c.v5_norm, c.v6_norm,
  c.ctr_raw, c.ctr_prob, c.ctr_rank, c.ctr_position,
  c.v1_discount_score, c.avg_discount_pct, c.discount_interaction_pct,
  v.v3_score, v.v4_score, v.v3_norm, v.v4_norm,
  v.conv_raw, v.conv_prob, v.conv_rank,
  v.max_funnel_stage, v.events_at_max_stage,
  (c.ctr_rank=1) AS is_top_ctr_brand,
  (v.conv_rank=1) AS is_top_conv_brand,
  (c.ctr_rank=1 AND v.conv_rank=1) AS ctr_conv_aligned
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step4_ctr_affinity_v2` c
FULL OUTER JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step7_conv_affinity_v2` v
  USING (ucid, brand);
