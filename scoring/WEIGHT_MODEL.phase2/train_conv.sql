-- Train Conv weight model with user-level split to prevent overfitting
CREATE OR REPLACE MODEL
  `zeotap-dev-datascience.FEL_eu_west3.brand_weight_model_final`
OPTIONS(
  model_type='LOGISTIC_REG', INPUT_LABEL_COLS=['purchased'],
  MAX_ITERATIONS=20, L1_REG=0.1,
  CLASS_WEIGHTS=[('0', 1.0), ('1', 27.0)]
) AS
SELECT
  COALESCE(f.v1_norm,0) AS v1, COALESCE(f.v5_norm,0) AS v5,
  COALESCE(f.v6_norm,0) AS v6, COALESCE(c.v3_norm,0) AS v3,
  COALESCE(c.v4_norm,0) AS v4,
  COALESCE(v1d.avg_discount_pct,0) AS avg_discount_pct,
  COALESCE(v1d.discount_interaction_pct,0) AS discount_pct,
  CAST(CASE WHEN p.ucid IS NOT NULL THEN 1 ELSE 0 END AS STRING) AS purchased
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step4_ctr_affinity_v2` f
LEFT JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step7_conv_affinity_v2` c USING (ucid, brand)
LEFT JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step1_v1_recency_v2` v1d USING (ucid, brand)
LEFT JOIN (SELECT DISTINCT ucid, brand FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step0_holdout_v2`) p USING (ucid, brand)
WHERE MOD(ABS(FARM_FINGERPRINT(f.ucid)), 10) < 8;  -- 80% user-level train split

-- Actuals: v3=19.251, v4=3.984, v1=-1.318 (negative when V3 present)
-- v3 negative sign explained: post-purchase browsing ≠ buying intent
