-- Step 09: Conversion Affinity V2
-- V3=82.9%, V4=17.1% (proven by logistic regression)

CREATE OR REPLACE TABLE
  `zeotap-dev-datascience.FEL_eu_west3.brand_step7_conv_affinity_v2`
AS
WITH joined AS (
  SELECT v4.ucid, v4.brand, v4.v4_score, v4.max_funnel_stage,
    v4.events_at_max_stage, COALESCE(v3.v3_score,0.0) AS v3_score
  FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step6_v4_funnel_v2` v4
  LEFT JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step5_v3_rfm_v2` v3 USING (ucid,brand)
),
quantiles AS (
  SELECT brand,
    APPROX_QUANTILES(v4_score,100)[OFFSET(1)]  AS v4_p1,
    APPROX_QUANTILES(v4_score,100)[OFFSET(99)] AS v4_p99,
    APPROX_QUANTILES(v3_score,100)[OFFSET(1)]  AS v3_p1,
    APPROX_QUANTILES(v3_score,100)[OFFSET(99)] AS v3_p99
  FROM joined GROUP BY brand
),
normalized AS (
  SELECT j.*,
    COALESCE(SAFE_DIVIDE(LEAST(GREATEST(j.v3_score,q.v3_p1),q.v3_p99)-q.v3_p1,q.v3_p99-q.v3_p1),0.0) AS v3_norm,
    COALESCE(SAFE_DIVIDE(LEAST(GREATEST(j.v4_score,q.v4_p1),q.v4_p99)-q.v4_p1,q.v4_p99-q.v4_p1),0.5) AS v4_norm
  FROM joined j JOIN quantiles q USING (brand)
),
combined AS (SELECT *, (0.8287*v3_norm)+(0.1713*v4_norm) AS conv_raw FROM normalized)
SELECT *,
  SAFE_DIVIDE(conv_raw, SUM(conv_raw) OVER (PARTITION BY ucid)) AS conv_prob,
  RANK() OVER (PARTITION BY ucid ORDER BY conv_raw DESC) AS conv_rank
FROM combined;
