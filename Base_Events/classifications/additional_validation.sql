--NULL EVENTS 
SELECT
  COUNT(DISTINCT ucid)              AS null_event_users
FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
WHERE ucid IN (
  SELECT ucid
  FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
  GROUP BY ucid
  HAVING COUNTIF(product_brand IS NOT NULL) = 0
)
GROUP BY ucid
HAVING MAX(CASE WHEN event_name IS NULL
  THEN 1 ELSE 0 END) = 1
AND MAX(CASE WHEN event_name IS NOT NULL
  THEN 1 ELSE 0 END) = 0;

--cookie sync
SELECT
  COUNT(DISTINCT ucid)              AS cookie_sync_users
FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
WHERE ucid IN (
  SELECT ucid
  FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
  GROUP BY ucid
  HAVING COUNTIF(product_brand IS NOT NULL) = 0
)
GROUP BY ucid
HAVING MAX(CASE WHEN event_name =
  'zeotap_cookie_sync'
  THEN 1 ELSE 0 END) = 1
AND MAX(CASE WHEN event_name IS NOT NULL
  AND event_name != 'zeotap_cookie_sync'
  THEN 1 ELSE 0 END) = 0;
--gift cards
SELECT
  product_name,
  product_id,
  COUNT(DISTINCT ucid)              AS users,
  COUNT(*)                          AS events
FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
WHERE LOWER(product_name) = 'giftcard'
OR LOWER(product_name) LIKE '%gutschein%'
AND ucid IN (
  SELECT ucid
  FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
  GROUP BY ucid
  HAVING COUNTIF(product_brand IS NOT NULL) = 0
)
GROUP BY product_name, product_id
ORDER BY users DESC;

--final count check 
-- This is the master check
-- All groups must add up to 7,973,806
SELECT
  user_type,
  COUNT(DISTINCT ucid)              AS users
FROM (
  SELECT ucid,
    CASE
      WHEN MAX(CASE WHEN event_name IS NULL
        THEN 1 ELSE 0 END) = 1
        AND MAX(CASE WHEN event_name
          IS NOT NULL
          THEN 1 ELSE 0 END) = 0
        THEN 'NULL Events Only'
      WHEN MAX(CASE WHEN event_name =
        'zeotap_cookie_sync'
        THEN 1 ELSE 0 END) = 1
        AND MAX(CASE WHEN event_name
          IS NOT NULL
          AND event_name !=
          'zeotap_cookie_sync'
          THEN 1 ELSE 0 END) = 0
        THEN 'Cookie Sync Only'
      WHEN MAX(CASE WHEN event_name IN (
        'product_view','add_to_cart',
        'add_to_wishlist','view_cart')
        THEN 1 ELSE 0 END) = 1
        AND MAX(CASE WHEN
          LOWER(product_name) = 'giftcard'
          OR LOWER(product_name)
            LIKE '%gutschein%'
          THEN 1 ELSE 0 END) = 0
        THEN 'Browser No Purchase'
      WHEN MAX(CASE WHEN
        LOWER(product_name) = 'giftcard'
        OR LOWER(product_name)
          LIKE '%gutschein%'
        THEN 1 ELSE 0 END) = 1
        THEN 'Gift Card Users'
      WHEN MAX(CASE WHEN event_name IN (
        'filter_usage','search_usage',
        'page_view','successful_login',
        'app_open') THEN 1 ELSE 0 END) = 1
        AND MAX(CASE WHEN event_name IN (
          'product_view','add_to_cart',
          'add_to_wishlist','view_cart',
          'purchase') THEN 1 ELSE 0 END) = 0
        THEN 'Engaged No Brand'
      ELSE 'Mixed/Other'
    END                             AS user_type
  FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
  WHERE ucid IN (
    SELECT ucid
    FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
    GROUP BY ucid
    HAVING COUNTIF(product_brand IS NOT NULL) = 0
  )
  GROUP BY ucid
)
GROUP BY user_type
ORDER BY users DESC;
-- Total must = 7,973,806
