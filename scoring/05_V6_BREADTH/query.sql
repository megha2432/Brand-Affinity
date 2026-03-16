-- Step 05: V6 Breadth Score

CREATE OR REPLACE TABLE
  `zeotap-dev-datascience.FEL_eu_west3.brand_step3_v6_breadth_v2`
AS
SELECT
  ucid, brand,
  COUNT(DISTINCT product_id)              AS n_unique_products,
  AVG(intent_weight)                      AS avg_intent_depth,
  COUNT(DISTINCT product_id) * AVG(intent_weight) AS v6_score
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step0_train_v2`
WHERE intent_weight > 0
  AND product_id IS NOT NULL AND TRIM(product_id) != ''
GROUP BY ucid, brand;
