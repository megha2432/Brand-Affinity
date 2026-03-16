-- Step 07: V4 Funnel Depth Score

CREATE OR REPLACE TABLE
  `zeotap-dev-datascience.FEL_eu_west3.brand_step6_v4_funnel_v2`
AS
WITH max_stage AS (
  SELECT ucid, brand, MAX(funnel_stage) AS max_funnel_stage
  FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step0_train_v2`
  WHERE funnel_stage > 0 GROUP BY ucid, brand
),
events_at_max AS (
  SELECT t.ucid, t.brand, COUNT(*) AS events_at_max_stage
  FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step0_train_v2` t
  JOIN max_stage m ON t.ucid=m.ucid AND t.brand=m.brand
    AND t.funnel_stage=m.max_funnel_stage
  GROUP BY t.ucid, t.brand
)
SELECT m.ucid, m.brand, m.max_funnel_stage, e.events_at_max_stage,
  m.max_funnel_stage + (0.1 * e.events_at_max_stage) AS v4_score
FROM max_stage m JOIN events_at_max e USING (ucid, brand);
