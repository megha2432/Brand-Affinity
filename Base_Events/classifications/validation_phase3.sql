WITH blind_users AS (
  SELECT ucid
  FROM `zeotap-dev-datascience.FEL_eu_west3
        .event_store_30_days_real_partition`
  GROUP BY ucid
  HAVING COUNTIF(product_brand IS NOT NULL) = 0
),

browser_signal_users AS (
  SELECT
    ucid,
    MAX(CASE WHEN event_name IN (
      'product_view','add_to_cart',
      'add_to_wishlist','view_cart')
      THEN 1 ELSE 0 END)            AS has_shopping,
    MAX(CASE WHEN REGEXP_EXTRACT(
      LOWER(page_url),
      r'/marken/([^/?]+)') IS NOT NULL
      THEN 1 ELSE 0 END)            AS has_url,
    MAX(CASE WHEN used_filter
      LIKE 'marke:%'
      THEN 1 ELSE 0 END)            AS has_marke,
    MAX(CASE WHEN search_phrase
      IS NOT NULL
      THEN 1 ELSE 0 END)            AS has_search,
    MAX(CASE WHEN
      LOWER(product_name) LIKE '%gift%'
      OR LOWER(product_name)
        LIKE '%gutschein%'
      OR product_id = '1001613654'
      THEN 1 ELSE 0 END)            AS is_gift_card
  FROM `zeotap-dev-datascience.FEL_eu_west3
        .event_store_30_days_real_partition`
  WHERE ucid IN (SELECT ucid FROM blind_users)
  GROUP BY ucid
)

SELECT
  CASE
    WHEN has_shopping = 1
      AND (has_url = 1 OR has_marke = 1
        OR has_search = 1)
      AND is_gift_card = 0
      THEN 'Recovered - No Gift Card'
    WHEN has_shopping = 1
      AND (has_url = 1 OR has_marke = 1
        OR has_search = 1)
      AND is_gift_card = 1
      THEN 'Recovered - Also Gift Card'
    WHEN has_shopping = 1
      AND has_url = 0
      AND has_marke = 0
      AND has_search = 0
      AND is_gift_card = 1
      THEN 'Gift Card Only - No Signal'
    WHEN has_shopping = 1
      AND has_url = 0
      AND has_marke = 0
      AND has_search = 0
      AND is_gift_card = 0
      THEN 'Browser - Truly Nothing'
    ELSE 'Other'
  END                               AS user_category,
  COUNT(DISTINCT ucid)              AS users
FROM browser_signal_users
WHERE has_shopping = 1
GROUP BY user_category
ORDER BY users DESC;
