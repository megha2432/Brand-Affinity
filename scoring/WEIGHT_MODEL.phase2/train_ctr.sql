-- Train CTR weight model (no V3 to prevent leakage)
CREATE OR REPLACE MODEL
  `zeotap-dev-datascience.FEL_eu_west3.brand_weight_model_no_v3`
OPTIONS(
  model_type='LOGISTIC_REG', INPUT_LABEL_COLS=['purchased'],
  MAX_ITERATIONS=20, L1_REG=0.1,
  CLASS_WEIGHTS=[('0', 1.0), ('1', 27.0)]  -- fix 96.48% imbalance
) AS
SELECT
  COALESCE(f.v1_norm, 0) AS v1, COALESCE(f.v5_norm, 0) AS v5,
  COALESCE(f.v6_norm, 0) AS v6, COALESCE(c.v4_norm, 0) AS v4,
  COALESCE(v1d.avg_discount_pct, 0) AS avg_discount_pct,
  COALESCE(v1d.discount_interaction_pct, 0) AS discount_pct,
  CAST(CASE WHEN p.ucid IS NOT NULL THEN 1 ELSE 0 END AS STRING) AS purchased
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step4_ctr_affinity_v2` f
LEFT JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step7_conv_affinity_v2` c USING (ucid, brand)
LEFT JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step1_v1_recency_v2` v1d USING (ucid, brand)
LEFT JOIN (SELECT DISTINCT ucid, brand FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step0_holdout_v2`) p USING (ucid, brand);

-- Get weights
SELECT processed_input AS signal, weight, ABS(weight) AS abs_weight
FROM ML.WEIGHTS(MODEL `zeotap-dev-datascience.FEL_eu_west3.brand_weight_model_no_v3`)
ORDER BY ABS(weight) DESC;
-- Actuals: v4=3.272, v1=2.193, v6=0.287, v5=-0.146 (negative→excluded)
