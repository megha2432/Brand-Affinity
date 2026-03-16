-- Validate AFTER: V3 RFM
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT ucid) AS distinct_buyers,
  COUNTIF(v3_score < 0 OR v3_score > 1) AS out_of_range,
  COUNTIF(frequency_raw < 1) AS zero_frequency,
  ROUND(AVG(frequency_raw), 2) AS avg_frequency,
  ROUND(AVG(monetary_raw), 2) AS avg_spend
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step5_v3_rfm_v2`;
-- PASS: out_of_range=0, zero_frequency=0
-- Phase 2 actuals: 815,421 rows, 350,052 buyers, avg_spend=€190.21
