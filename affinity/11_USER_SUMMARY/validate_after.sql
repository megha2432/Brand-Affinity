-- Validate AFTER: User Summary
SELECT
  COUNT(*) AS total_rows, COUNT(DISTINCT ucid) AS distinct_users,
  COUNTIF(top_ctr_brand IS NULL) AS missing_ctr,
  COUNTIF(top_conv_brand IS NULL) AS missing_conv,
  COUNTIF(ctr_conv_agree) AS both_agree,
  ROUND(SAFE_DIVIDE(COUNTIF(ctr_conv_agree),COUNT(*))*100,2) AS agreement_pct,
  ROUND(AVG(n_active_brands),2) AS avg_brands_per_user
FROM `zeotap-dev-datascience.FEL_eu_west3.brand_step9_user_summary_v2`;
-- PASS: total_rows = distinct_users (one row per user), missing_ctr=0
-- Phase 2 actuals: agreement_pct=82.99%, avg_brands=3.74
