--Signal 1 Query — URL Brand
sqlSELECT
  COUNT(DISTINCT ucid)              AS url_brand_users
FROM `zeotap-dev-datascience.FEL_eu_west3
      .event_store_30_days_real_partition`
WHERE REGEXP_EXTRACT(
  LOWER(page_url),
  r'/marken/([^/?]+)') IS NOT NULL
AND ucid IN (
  SELECT ucid
  FROM `zeotap-dev-datascience.FEL_eu_west3
        .event_store_30_days_real_partition`
  GROUP BY ucid
  HAVING COUNTIF(product_brand IS NOT NULL) = 0
);
--Signal 2 Query — marke Filter
SELECT
  REPLACE(TRIM(brand), '-', ' ')    AS brand,
  COUNT(DISTINCT ucid)              AS users
FROM (
  SELECT ucid,
    REGEXP_EXTRACT(
      LOWER(used_filter),
      r'marke:([^|,]+)')            AS brand_raw
  FROM `zeotap-dev-datascience.FEL_eu_west3
        .event_store_30_days_real_partition`
  WHERE used_filter LIKE 'marke:%'
  AND ucid IN (
    SELECT ucid
    FROM `zeotap-dev-datascience.FEL_eu_west3
          .event_store_30_days_real_partition`
    GROUP BY ucid
    HAVING COUNTIF(product_brand IS NOT NULL) = 0
  )
) f
CROSS JOIN UNNEST(SPLIT(brand_raw, ',')) AS brand
WHERE TRIM(brand) != ''
GROUP BY brand
ORDER BY users DESC;
--Signal 3 Query — Brand Search
SELECT
  b.brand,
  COUNT(DISTINCT e.ucid)            AS users
FROM `zeotap-dev-datascience.FEL_eu_west3
      .event_store_30_days_real_partition` e
JOIN (
  SELECT DISTINCT LOWER(product_brand) AS brand
  FROM `zeotap-dev-datascience.FEL_eu_west3
        .event_store_30_days_real_partition`
  WHERE product_brand IS NOT NULL
  AND LENGTH(product_brand) >= 3
) b
  ON LOWER(e.search_phrase)
    LIKE CONCAT('%', b.brand, '%')
WHERE e.search_phrase IS NOT NULL
AND e.ucid IN (
  SELECT ucid
  FROM `zeotap-dev-datascience.FEL_eu_west3
        .event_store_30_days_real_partition`
  GROUP BY ucid
  HAVING COUNTIF(product_brand IS NOT NULL) = 0
)
GROUP BY b.brand
ORDER BY users DESC;
--Signal 4 Query — URL Search Term
SELECT
  b.brand,
  COUNT(DISTINCT e.ucid)            AS users
FROM `zeotap-dev-datascience.FEL_eu_west3
      .event_store_30_days_real_partition` e
JOIN (
  SELECT DISTINCT LOWER(product_brand) AS brand
  FROM `zeotap-dev-datascience.FEL_eu_west3
        .event_store_30_days_real_partition`
  WHERE product_brand IS NOT NULL
  AND LENGTH(product_brand) >= 3
) b
  ON LOWER(REPLACE(
    REGEXP_EXTRACT(e.page_url, r'[?&]q=([^&]+)'),
    '+', ' '))
    LIKE CONCAT('%', b.brand, '%')
WHERE e.page_url IS NOT NULL
AND e.ucid IN (
  SELECT ucid
  FROM `zeotap-dev-datascience.FEL_eu_west3
        .event_store_30_days_real_partition`
  GROUP BY ucid
  HAVING COUNTIF(product_brand IS NOT NULL) = 0
)
GROUP BY b.brand
ORDER BY users DESC;
--Signal 5 Query — Category URL
SELECT
  CASE
    WHEN LOWER(page_url) LIKE '%/damen/schuhe%'
      THEN 'Women Shoes'
    WHEN LOWER(page_url) LIKE '%/herren/schuhe%'
      THEN 'Men Shoes'
    WHEN LOWER(page_url) LIKE '%/damen/bekleidung%'
      THEN 'Women Clothing'
    WHEN LOWER(page_url) LIKE '%/herren/bekleidung%'
      THEN 'Men Clothing'
    WHEN LOWER(page_url) LIKE '%/damen/taschen%'
      THEN 'Women Bags'
    WHEN LOWER(page_url) LIKE '%/sport%'
      THEN 'Sports'
    WHEN LOWER(page_url) LIKE '%/damen/%'
      THEN 'Women General'
    WHEN LOWER(page_url) LIKE '%/herren/%'
      THEN 'Men General'
    WHEN LOWER(page_url) LIKE '%/sale%'
      OR LOWER(page_url) LIKE '%/last-chance%'
      THEN 'Sale'
    ELSE 'Other'
  END                               AS url_category,
  COUNT(DISTINCT ucid)              AS users
FROM `zeotap-dev-datascience.FEL_eu_west3
      .event_store_30_days_real_partition`
WHERE page_url IS NOT NULL
AND ucid IN (
  SELECT ucid
  FROM `zeotap-dev-datascience.FEL_eu_west3
        .event_store_30_days_real_partition`
  GROUP BY ucid
  HAVING COUNTIF(product_brand IS NOT NULL) = 0
)
GROUP BY url_category
ORDER BY users DESC;



