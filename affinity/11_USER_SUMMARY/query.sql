-- Step 11: User Summary
CREATE OR REPLACE TABLE
  `zeotap-dev-datascience.FEL_eu_west3.brand_step9_user_summary_v2`
AS
SELECT
  ucid,
  MAX(CASE WHEN ctr_rank=1 THEN brand END) AS top_ctr_brand,
  MAX(CASE WHEN ctr_rank=1 THEN ctr_prob END) AS ctr_confidence,
  MAX(CASE WHEN conv_rank=1 THEN brand END) AS top_conv_brand,
  MAX(CASE WHEN conv_rank=1 THEN conv_prob END) AS conv_confidence,
  COUNT(DISTINCT brand) AS n_active_brands,
  MAX(CASE WHEN ctr_rank=1 THEN brand END) =
  MAX(CASE WHEN conv_rank=1 THEN brand END) AS ctr_conv_agree,
  ROUND(AVG(avg_discount_pct),2) AS avg_discount_pct,
  ROUND(AVG(discount_interaction_pct),2) AS avg_discount_interaction_pct
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step8_affinity_final_v2`
GROUP BY ucid;
