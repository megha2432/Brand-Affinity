-- Step 12: Brand Affinity Simple View
-- Fixed buyer_type: purchase-based not browse-based

CREATE OR REPLACE TABLE
  `zeotap-dev-datascience.FEL_eu_west3.brand_affinity_simple_view`
AS
WITH purchases AS (
  SELECT ucid, brand, COUNT(*) AS purchases,
    ROUND(SUM(monetary_value),2) AS total_spend,
    MIN(days_ago) AS days_since_last_purchase,
    ROUND(SAFE_DIVIDE(COUNTIF(discount_factor>0),COUNT(*))*100,2) AS purchase_discount_pct
  FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step0_holdout_v2`
  GROUP BY ucid, brand
),
user_max AS (
  SELECT ucid, MAX(ctr_raw) AS max_ctr_raw
  FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step4_ctr_affinity_v2`
  GROUP BY ucid
)
SELECT
  f.ucid, f.brand,
  ROW_NUMBER() OVER (PARTITION BY f.ucid ORDER BY f.ctr_raw DESC, f.brand ASC) AS rank,
  COALESCE(v1.v1_event_count,0) AS interactions,
  COALESCE(p.purchases,0) AS purchases,
  ROUND(COALESCE(p.total_spend,0),2) AS spend,
  p.days_since_last_purchase AS days_since_purchase,
  ROUND(f.ctr_prob,6) AS ctr_brand_prob,
  ROUND(COALESCE(c.conv_prob,0),6) AS conv_brand_prob,
  ROUND(SAFE_DIVIDE(f.ctr_raw,m.max_ctr_raw)*100,1) AS affinity_score,
  CASE
    WHEN SAFE_DIVIDE(f.ctr_raw,m.max_ctr_raw)>=0.75 THEN 'Very High'
    WHEN SAFE_DIVIDE(f.ctr_raw,m.max_ctr_raw)>=0.50 THEN 'High'
    WHEN SAFE_DIVIDE(f.ctr_raw,m.max_ctr_raw)>=0.25 THEN 'Medium'
    WHEN SAFE_DIVIDE(f.ctr_raw,m.max_ctr_raw)>=0.10 THEN 'Low'
    ELSE 'Very Low'
  END AS affinity_band,
  COALESCE(v1.v1_score,0) AS v1_recency_score,
  COALESCE(v5.v5_score,0) AS v5_velocity_score,
  COALESCE(v3.v3_score,0) AS v3_rfm_score,
  COALESCE(v4.max_funnel_stage,0) AS max_funnel_stage,
  -- FIXED buyer_type logic
  CASE
    WHEN COALESCE(p.purchases,0)=0 THEN
      CASE WHEN COALESCE(v1.discount_interaction_pct,0)>=70 THEN 'Browser (Sale Driven)'
           WHEN COALESCE(v1.discount_interaction_pct,0)>=30 THEN 'Browser (Mixed)'
           ELSE 'Browser (Full Price)' END
    ELSE
      CASE WHEN COALESCE(p.purchase_discount_pct,0)>=70 THEN 'Sale Buyer'
           WHEN COALESCE(p.purchase_discount_pct,0)>=30 THEN 'Occasional Sale'
           ELSE 'Full Price Buyer' END
  END AS buyer_type,
  ROUND(COALESCE(v1.avg_discount_pct,0),1) AS avg_discount_pct
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step4_ctr_affinity_v2` f
LEFT JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step1_v1_recency_v2` v1 USING (ucid,brand)
LEFT JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step2_v5_velocity_v2` v5 USING (ucid,brand)
LEFT JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step5_v3_rfm_v2` v3 USING (ucid,brand)
LEFT JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step6_v4_funnel_v2` v4 USING (ucid,brand)
LEFT JOIN `zeotap-dev-datascience.FEL_eu_west3.brand_step7_conv_affinity_v2` c USING (ucid,brand)
LEFT JOIN purchases p USING (ucid,brand)
JOIN user_max m USING (ucid);
