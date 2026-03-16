-- Validate AFTER: Simple View
-- Check buyer_type is correct (purchase-based not browse-based)
SELECT
  buyer_type,
  COUNT(DISTINCT ucid) AS users,
  COUNTIF(purchases=0) AS zero_purchase_users,
  COUNTIF(purchases>0) AS has_purchase_users
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_affinity_simple_view`
WHERE rank=1
GROUP BY buyer_type ORDER BY users DESC;
-- PASS: 'Sale Buyer','Occasional Sale','Full Price Buyer' → all have purchases>0
-- PASS: 'Browser (*)' types → all have purchases=0
