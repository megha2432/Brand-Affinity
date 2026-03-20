--Signal 1 Query — URL Brand

SELECT COUNT(DISTINCT ucid) AS url_brand_users
FROM ...
WHERE REGEXP_EXTRACT(LOWER(page_url),
  r'/marken/([^/?]+)') IS NOT NULL
AND ucid IN (blind_users)

-- CORRECT (only url primary - no marke):
SELECT COUNT(DISTINCT ucid) AS url_brand_users
FROM ...
WHERE REGEXP_EXTRACT(LOWER(page_url),
  r'/marken/([^/?]+)') IS NOT NULL
AND ucid IN (blind_users)
AND ucid NOT IN (
  SELECT ucid FROM ...
  WHERE used_filter LIKE 'marke:%'
  AND ucid IN (blind_users)
);
--Signal 2 Query — marke Filter

SELECT
  COUNT(DISTINCT ucid)              AS total_marke_users,
  COUNT(DISTINCT REPLACE(
    TRIM(brand), '-', ' '))         AS unique_brands
FROM (
  SELECT
    ucid,
    brand
  FROM (
    SELECT ucid,
      REGEXP_EXTRACT(
        LOWER(used_filter),
        r'marke:([^|,]+)')          AS brand_raw
    FROM `zeotap-dev-datascience.FEL_eu_west3
          .event_store_30_days_real_partition`
    WHERE used_filter LIKE 'marke:%'
    AND ucid IN (
      SELECT ucid FROM ...
      GROUP BY ucid
      HAVING COUNTIF(product_brand
        IS NOT NULL) = 0
    )
  ) f
  CROSS JOIN UNNEST(SPLIT(brand_raw, ',')) AS brand
  WHERE TRIM(brand) != ''
);
--Signal 3 Query — Brand Search
SELECT
  COUNT(DISTINCT e.ucid)            AS brand_search_users
FROM `zeotap-dev-datascience.FEL_eu_west3
      .event_store_30_days_real_partition` e
JOIN (
  SELECT DISTINCT
    LOWER(product_brand)            AS brand
  FROM `zeotap-dev-datascience.FEL_eu_west3
        .event_store_30_days_real_partition`
  WHERE product_brand IS NOT NULL
  AND LENGTH(product_brand) >= 3
) b
  ON LOWER(e.search_phrase)
    LIKE CONCAT('%', b.brand, '%')
WHERE e.search_phrase IS NOT NULL
-- exclude marke and url users
AND e.ucid NOT IN (
  SELECT ucid FROM ...
  WHERE used_filter LIKE 'marke:%'
  AND ucid IN (blind_users)
)
AND e.ucid NOT IN (
  SELECT ucid FROM ...
  WHERE REGEXP_EXTRACT(
    LOWER(page_url),
    r'/marken/([^/?]+)') IS NOT NULL
  AND ucid IN (blind_users)
)
AND e.ucid IN (blind_users);
--Signal 4 Query — URL Search Term

SELECT
  COUNT(DISTINCT e.ucid)            AS url_search_users
FROM `zeotap-dev-datascience.FEL_eu_west3
      .event_store_30_days_real_partition` e
JOIN (
  SELECT DISTINCT
    LOWER(product_brand)            AS brand
  FROM `zeotap-dev-datascience.FEL_eu_west3
        .event_store_30_days_real_partition`
  WHERE product_brand IS NOT NULL
  AND LENGTH(product_brand) >= 3
) b
  ON LOWER(REPLACE(
    REGEXP_EXTRACT(e.page_url,
      r'[?&]q=([^&]+)'),
    '+', ' '))
    LIKE CONCAT('%', b.brand, '%')
WHERE e.page_url IS NOT NULL
-- must be on search result page
AND e.page_title = 'searchresult_list'
-- exclude higher priority signals
AND e.ucid NOT IN (
  SELECT ucid FROM ...
  WHERE used_filter LIKE 'marke:%'
  AND ucid IN (blind_users)
)
AND e.ucid NOT IN (
  SELECT ucid FROM ...
  WHERE REGEXP_EXTRACT(
    LOWER(page_url),
    r'/marken/([^/?]+)') IS NOT NULL
  AND ucid IN (blind_users)
)
AND e.ucid NOT IN (
  SELECT ucid FROM ...
  JOIN brand_list b
    ON LOWER(search_phrase)
      LIKE CONCAT('%', b.brand, '%')
  WHERE search_phrase IS NOT NULL
  AND ucid IN (blind_users)
)
AND e.ucid IN (blind_users);
--Signal 5 Query — Category URL

SELECT
  url_category,
  COUNT(DISTINCT ucid)              AS users
FROM (
  SELECT
    ucid,
    CASE
      WHEN LOWER(page_url)
        LIKE '%/damen/schuhe%'
        THEN 'Women Shoes'
      WHEN LOWER(page_url)
        LIKE '%/herren/schuhe%'
        THEN 'Men Shoes'
      WHEN LOWER(page_url)
        LIKE '%/damen/bekleidung%'
        THEN 'Women Clothing'
      WHEN LOWER(page_url)
        LIKE '%/herren/bekleidung%'
        THEN 'Men Clothing'
      WHEN LOWER(page_url)
        LIKE '%/damen/taschen%'
        THEN 'Women Bags'
      WHEN LOWER(page_url)
        LIKE '%/sport%'
        THEN 'Sports'
      WHEN LOWER(page_url)
        LIKE '%/damen/%'
        THEN 'Women General'
      WHEN LOWER(page_url)
        LIKE '%/herren/%'
        THEN 'Men General'
      WHEN LOWER(page_url)
        LIKE '%/sale%'
        OR LOWER(page_url)
          LIKE '%/last-chance%'
        THEN 'Sale'
      ELSE NULL  -- exclude Other
    END                             AS url_category
  FROM `zeotap-dev-datascience.FEL_eu_west3
        .event_store_30_days_real_partition`
  WHERE page_url IS NOT NULL
  -- exclude higher priority signals
  AND ucid NOT IN (
    SELECT ucid FROM ...
    WHERE used_filter LIKE 'marke:%'
    AND ucid IN (blind_users)
  )
  AND ucid NOT IN (
    SELECT ucid FROM ...
    WHERE REGEXP_EXTRACT(
      LOWER(page_url),
      r'/marken/([^/?]+)') IS NOT NULL
    AND ucid IN (blind_users)
  )
  AND ucid NOT IN (
    SELECT ucid FROM ...
    JOIN brand_list b
      ON LOWER(search_phrase)
        LIKE CONCAT('%', b.brand, '%')
    WHERE search_phrase IS NOT NULL
    AND ucid IN (blind_users)
  )
  AND ucid NOT IN (
    SELECT ucid FROM ...
    JOIN brand_list b
      ON LOWER(REPLACE(
        REGEXP_EXTRACT(page_url,
          r'[?&]q=([^&]+)'),
        '+', ' '))
        LIKE CONCAT('%', b.brand, '%')
    WHERE page_url IS NOT NULL
    AND ucid IN (blind_users)
  )
  AND ucid IN (blind_users)
)
WHERE url_category IS NOT NULL  -- exclude Other
GROUP BY url_category
ORDER BY users DESC;
--master validation 
WITH blind_users AS (
  SELECT ucid
  FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
  GROUP BY ucid
  HAVING COUNTIF(product_brand IS NOT NULL) = 0
),

brand_list AS (
  SELECT DISTINCT
    LOWER(product_brand)            AS brand
  FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
  WHERE product_brand IS NOT NULL
  AND LENGTH(product_brand) >= 3
),

all_signals AS (
  SELECT
    ucid,
    MAX(CASE WHEN REGEXP_EXTRACT(
      LOWER(page_url),
      r'/marken/([^/?]+)') IS NOT NULL
      THEN 1 ELSE 0 END)            AS has_url,
    MAX(CASE WHEN used_filter
      LIKE 'marke:%'
      THEN 1 ELSE 0 END)            AS has_marke,
    MAX(CASE WHEN EXISTS (
      SELECT 1 FROM brand_list b
      WHERE LOWER(search_phrase)
        LIKE CONCAT('%', b.brand, '%')
    ) THEN 1 ELSE 0 END)            AS has_search,
    MAX(CASE WHEN EXISTS (
      SELECT 1 FROM brand_list b
      WHERE LOWER(REPLACE(
        REGEXP_EXTRACT(page_url,
          r'[?&]q=([^&]+)'),
        '+', ' '))
        LIKE CONCAT('%', b.brand, '%')
    ) THEN 1 ELSE 0 END)            AS has_url_search,
    MAX(CASE WHEN
      LOWER(page_url) LIKE '%/damen/%'
      OR LOWER(page_url) LIKE '%/herren/%'
      OR LOWER(page_url) LIKE '%/sport%'
      THEN 1 ELSE 0 END)            AS has_category
  FROM `zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition`
  WHERE ucid IN (SELECT ucid FROM blind_users)
  GROUP BY ucid
)

SELECT
  -- non overlapping counts
  -- using priority order
  COUNTIF(has_marke = 1)            AS marke_any,
  COUNTIF(has_url = 1
    AND has_marke = 0)              AS url_primary,
  COUNTIF(has_search = 1
    AND has_url = 0
    AND has_marke = 0)              AS search_primary,
  COUNTIF(has_url_search = 1
    AND has_search = 0
    AND has_url = 0
    AND has_marke = 0)              AS url_search_primary,
  COUNTIF(has_category = 1
    AND has_url_search = 0
    AND has_search = 0
    AND has_url = 0
    AND has_marke = 0)              AS category_primary,
  COUNTIF(has_url = 0
    AND has_marke = 0
    AND has_search = 0
    AND has_url_search = 0
    AND has_category = 0)           AS nothing,

  -- total should = 7,973,806
  COUNT(*)                          AS total_blind_users
FROM all_signals;


