-- Step 06: V3 RFM Score (from holdout purchases only)

CREATE OR REPLACE TABLE
  `zeotap-dev-datascience.FEL_eu_west3.brand_step5_v3_rfm_v2`
AS
WITH rfm_raw AS (
  SELECT ucid, brand,
    MIN(days_ago) AS days_since_last_purchase,
    1.0 / (1.0 + MIN(days_ago)) AS recency_raw,
    COUNT(*) AS frequency_raw,
    SUM(monetary_value) AS monetary_raw,
    ROUND(AVG(discount_factor)*100, 2) AS avg_purchase_discount_pct,
    ROUND(SAFE_DIVIDE(COUNTIF(discount_factor>0), COUNT(*))*100, 2)
      AS pct_purchases_on_discount
  FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step0_holdout_v2`
  GROUP BY ucid, brand
),
quantiles AS (
  SELECT brand,
    APPROX_QUANTILES(recency_raw,100)[OFFSET(1)]   AS r_p1,
    APPROX_QUANTILES(recency_raw,100)[OFFSET(99)]  AS r_p99,
    APPROX_QUANTILES(frequency_raw,100)[OFFSET(1)] AS f_p1,
    APPROX_QUANTILES(frequency_raw,100)[OFFSET(99)]AS f_p99,
    APPROX_QUANTILES(monetary_raw,100)[OFFSET(1)]  AS m_p1,
    APPROX_QUANTILES(monetary_raw,100)[OFFSET(99)] AS m_p99
  FROM rfm_raw GROUP BY brand
)
SELECT r.*,
  CASE WHEN r.pct_purchases_on_discount >= 70 THEN 'Sale Buyer'
       WHEN r.pct_purchases_on_discount >= 30 THEN 'Occasional Sale'
       ELSE 'Full Price Buyer' END AS buyer_type,
  COALESCE(SAFE_DIVIDE(
    LEAST(GREATEST(r.recency_raw,q.r_p1),q.r_p99)-q.r_p1,
    q.r_p99-q.r_p1), 0.5) AS r_norm,
  COALESCE(SAFE_DIVIDE(
    LEAST(GREATEST(r.frequency_raw,q.f_p1),q.f_p99)-q.f_p1,
    q.f_p99-q.f_p1), 0.5) AS f_norm,
  COALESCE(SAFE_DIVIDE(
    LEAST(GREATEST(r.monetary_raw,q.m_p1),q.m_p99)-q.m_p1,
    q.m_p99-q.m_p1), 0.5) AS m_norm,
  (COALESCE(SAFE_DIVIDE(LEAST(GREATEST(r.recency_raw,q.r_p1),q.r_p99)-q.r_p1,q.r_p99-q.r_p1),0.5) +
   COALESCE(SAFE_DIVIDE(LEAST(GREATEST(r.frequency_raw,q.f_p1),q.f_p99)-q.f_p1,q.f_p99-q.f_p1),0.5) +
   COALESCE(SAFE_DIVIDE(LEAST(GREATEST(r.monetary_raw,q.m_p1),q.m_p99)-q.m_p1,q.m_p99-q.m_p1),0.5)
  ) / 3.0 AS v3_score
FROM rfm_raw r JOIN quantiles q USING (brand);
