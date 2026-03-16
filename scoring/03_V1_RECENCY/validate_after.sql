-- Validate AFTER: V1 Recency
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT ucid) AS distinct_users,
  COUNT(DISTINCT brand) AS distinct_brands,
  COUNTIF(v1_score < 0) AS negative_scores,
  ROUND(MAX(v1_score), 4) AS max_score,
  ROUND(AVG(v1_score), 4) AS avg_score,
  MAX(v1_event_count) AS max_events,
  COUNT(DISTINCT CONCAT(ucid,'|',brand)) AS distinct_pairs
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step1_v1_recency_v2`;
-- PASS: negative_scores=0, max_events<=1000, total_rows=distinct_pairs
-- Phase 2 actuals: 20.7M rows, 5.5M users, 1,721 brands, max_score=266
