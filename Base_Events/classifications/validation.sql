SELECT
  user_type,
  COUNT(DISTINCT ucid)              AS users
FROM (
  SELECT
    ucid,
    CASE
      WHEN MAX(CASE WHEN event_name IN (
        'product_view','add_to_cart',
        'add_to_wishlist','view_cart')
        THEN 1 ELSE 0 END) = 1
        THEN 'Browser No Purchase'
      WHEN MAX(CASE WHEN event_name IN (
        'filter_usage','search_usage',
        'page_view','successful_login',
        'app_open')
        THEN 1 ELSE 0 END) = 1
        AND MAX(CASE WHEN event_name IN (
          'product_view','add_to_cart',
          'add_to_wishlist','view_cart',
          'purchase')
          THEN 1 ELSE 0 END) = 0
        THEN 'Engaged No Brand'
      WHEN MAX(CASE WHEN event_name =
        'zeotap_cookie_sync'
        THEN 1 ELSE 0 END) = 1
        AND MAX(CASE WHEN event_name
          IS NOT NULL
          AND event_name !=
          'zeotap_cookie_sync'
          THEN 1 ELSE 0 END) = 0
        THEN 'Cookie Sync Only'
      WHEN MAX(CASE WHEN event_name
        IS NULL THEN 1 ELSE 0 END) = 1
        AND MAX(CASE WHEN event_name
          IS NOT NULL
          THEN 1 ELSE 0 END) = 0
        THEN 'NULL Events Only'
      ELSE 'Mixed'
    END                             AS user_type
  FROM `zeotap-dev-datascience.FEL_eu_west3
        .event_store_30_days_real_partition`
  WHERE ucid IN (
    SELECT ucid
    FROM `zeotap-dev-datascience.FEL_eu_west3
          .event_store_30_days_real_partition`
    GROUP BY ucid
    HAVING COUNTIF(product_brand
      IS NOT NULL) = 0
  )
  GROUP BY ucid
)
GROUP BY user_type
ORDER BY users DESC;
```
