# Phase 1 — User Segmentation
Finding
Has brand data  = 5,543,584  (41.0%)
No brand data   = 7,973,806  (59.0%)
─────────────────────────────────────
Total           = 13,517,390 ✅

SELECT
  COUNT(DISTINCT ucid)              AS total_users,
  COUNT(DISTINCT CASE WHEN
    product_brand IS NOT NULL
    THEN ucid END)                  AS has_brand_users,
  COUNT(DISTINCT CASE WHEN
    product_brand IS NULL
    THEN ucid END)                  AS no_brand_users
FROM `zeotap-dev-datascience.FEL_eu_west3
      .event_store_30_days_real_partition`;
