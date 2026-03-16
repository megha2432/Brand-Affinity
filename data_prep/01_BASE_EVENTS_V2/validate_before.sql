-- Validate BEFORE: 01 Base Events
SELECT
  COUNT(*) AS total_rows,
  ROUND(SAFE_DIVIDE(COUNTIF(product_brand IS NOT NULL
    AND TRIM(product_brand)!=''), COUNT(*)) * 100, 2) AS brand_fill_pct,
  COUNT(DISTINCT product_brand) AS distinct_brands,
  COUNTIF(reduced_price IS NOT NULL) AS has_reduced_price,
  COUNTIF(reference_price IS NOT NULL) AS has_reference_price
FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
WHERE event_name IN ('product_view','add_to_wishlist','view_cart','add_to_cart');
-- PASS: total_rows > 0, brand_fill_pct > 30
