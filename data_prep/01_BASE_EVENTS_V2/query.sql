-- ═══════════════════════════════════════════════════════════
-- Step 01: Brand Base Events V2
-- Output: brand_step0_train_v2 + brand_step0_holdout_v2
-- ═══════════════════════════════════════════════════════════

CREATE OR REPLACE TABLE
  `zeotap-dev-datascience.FEL_eu_west3.brand_step0_train_v2`
AS
WITH raw AS (
  SELECT
    ucid,
    event_name,
    product_brand                              AS brand,
    taxonomie_2                                AS category,
    product_id, product_name,
    product_price                              AS monetary_value,
    reduced_price, reference_price,
    _zeotap_timestamp,
    GREATEST(DATE_DIFF(
      DATE('2026-02-23'),
      DATE(_zeotap_timestamp), DAY), 0)        AS days_ago,
    CASE
      WHEN reference_price IS NULL OR reference_price = 0
        OR reduced_price IS NULL               THEN 0.0
      WHEN reduced_price >= reference_price    THEN 0.0
      ELSE ROUND(1.0 - SAFE_DIVIDE(
        reduced_price, reference_price), 4)
    END                                        AS discount_factor,
    CASE event_name
      WHEN 'add_to_cart'     THEN 0.60
      WHEN 'add_to_wishlist' THEN 0.45
      WHEN 'view_cart'       THEN 0.30
      WHEN 'product_view'    THEN 0.10
    END                                        AS intent_weight_base,
    CASE event_name
      WHEN 'product_view'    THEN 2
      WHEN 'add_to_wishlist' THEN 3
      WHEN 'add_to_cart'     THEN 4
      WHEN 'view_cart'       THEN 5
    END                                        AS funnel_stage
  FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
  WHERE event_name IN (
      'product_view','add_to_wishlist','view_cart','add_to_cart')
    AND product_brand IS NOT NULL AND TRIM(product_brand) != ''
    AND ucid IS NOT NULL AND TRIM(ucid) != ''
),
user_event_counts AS (
  SELECT ucid, COUNT(*) AS total_user_events FROM raw GROUP BY ucid
)
SELECT r.*,
  ROUND(intent_weight_base * (1.0 - discount_factor * 0.5), 4) AS intent_weight,
  ROUND(intent_weight_base * discount_factor, 4)               AS discount_signal
FROM raw r JOIN user_event_counts u USING (ucid)
WHERE u.total_user_events <= 1000;  -- bot filter

-- Holdout: purchases only
CREATE OR REPLACE TABLE
  `zeotap-dev-datascience.FEL_eu_west3.brand_step0_holdout_v2`
AS
SELECT ucid, product_brand AS brand, taxonomie_2 AS category,
  product_price AS monetary_value, reduced_price, reference_price,
  _zeotap_timestamp,
  DATE_DIFF(DATE('2026-02-23'), DATE(_zeotap_timestamp), DAY) AS days_ago,
  CASE WHEN reference_price IS NULL OR reference_price = 0
       OR reduced_price IS NULL THEN 0.0
       WHEN reduced_price >= reference_price THEN 0.0
       ELSE ROUND(1.0 - SAFE_DIVIDE(reduced_price, reference_price), 4)
  END AS discount_factor
FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
WHERE event_name = 'purchase'
  AND product_brand IS NOT NULL AND TRIM(product_brand) != ''
  AND ucid IS NOT NULL AND TRIM(ucid) != '';
