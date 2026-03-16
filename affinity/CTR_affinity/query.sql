-- Step 08: CTR Affinity V2 with proven weights
-- V4=57.3%, V1=38.4%, V6=5.0%, V5=excluded

CREATE OR REPLACE TABLE
  `zeotap-dev-datascience.FEL_eu_west3.brand_step4_ctr_affinity_v2`
AS
WITH joined AS (
  SELECT v1.ucid, v1.brand, v1.v1_score,
    COALESCE(v5.v5_score,0.5) AS v5_score,
    COALESCE(v6.v6_score,0.0) AS v6_score,
    COALESCE(v4.v4_score,0.0) AS v4_score,
    v1.v1_discount_score, v1.avg_discount_pct, v1.discount_interaction_pct
  FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step1_v1_recency_v2` v1
  LEFT JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step2_v5_velocity_v2` v5 USING (ucid,brand)
  LEFT JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step3_v6_breadth_v2` v6 USING (ucid,brand)
  LEFT JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step6_v4_funnel_v2` v4 USING (ucid,brand)
),
quantiles AS (
  SELECT brand,
    APPROX_QUANTILES(v1_score,100)[OFFSET(1)] AS v1_p1,
    APPROX_QUANTILES(v1_score,100)[OFFSET(99)] AS v1_p99,
    APPROX_QUANTILES(v5_score,100)[OFFSET(1)] AS v5_p1,
    APPROX_QUANTILES(v5_score,100)[OFFSET(99)] AS v5_p99,
    APPROX_QUANTILES(v6_score,100)[OFFSET(1)] AS v6_p1,
    APPROX_QUANTILES(v6_score,100)[OFFSET(99)] AS v6_p99,
    APPROX_QUANTILES(v4_score,100)[OFFSET(1)] AS v4_p1,
    APPROX_QUANTILES(v4_score,100)[OFFSET(99)] AS v4_p99
  FROM joined GROUP BY brand
),
normalized AS (
  SELECT j.*, j.v1_discount_score, j.avg_discount_pct, j.discount_interaction_pct,
    COALESCE(SAFE_DIVIDE(LEAST(GREATEST(j.v1_score,q.v1_p1),q.v1_p99)-q.v1_p1,q.v1_p99-q.v1_p1),0.5) AS v1_norm,
    COALESCE(SAFE_DIVIDE(LEAST(GREATEST(j.v5_score,q.v5_p1),q.v5_p99)-q.v5_p1,q.v5_p99-q.v5_p1),0.5) AS v5_norm,
    COALESCE(SAFE_DIVIDE(LEAST(GREATEST(j.v6_score,q.v6_p1),q.v6_p99)-q.v6_p1,q.v6_p99-q.v6_p1),0.0) AS v6_norm,
    COALESCE(SAFE_DIVIDE(LEAST(GREATEST(j.v4_score,q.v4_p1),q.v4_p99)-q.v4_p1,q.v4_p99-q.v4_p1),0.0) AS v4_norm
  FROM joined j JOIN quantiles q USING (brand)
),
combined AS (
  SELECT *,
    -- PROVEN WEIGHTS: V4=57.3%, V1=38.4%, V6=5.0%, V5=excluded
    (0.5729*v4_norm) + (0.3839*v1_norm) + (0.0503*v6_norm) AS ctr_raw
  FROM normalized
)
SELECT *,
  SAFE_DIVIDE(ctr_raw, SUM(ctr_raw) OVER (PARTITION BY ucid)) AS ctr_prob,
  RANK() OVER (PARTITION BY ucid ORDER BY ctr_raw DESC) AS ctr_rank,
  ROW_NUMBER() OVER (PARTITION BY ucid ORDER BY ctr_raw DESC, brand ASC) AS ctr_position
FROM combined;
