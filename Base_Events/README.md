Project: Breuninger Brand Affinity
Type: Data Science / Analysis
Priority: HIGH
Status: Analysis Complete — Implementation Pending

Background
Before building brand affinity model
we analyzed ALL 13.5M users to
understand data quality and coverage.

Source Table:
zeotap-dev-datascience.FEL_eu_west3
.event_store_30_days_real_partition

Date Range: Jan 24 – Feb 23 2026
Total Users: 13,517,390
Total Events: 372M rows
Total Brands: 1,721

Problem Statement
Initial assumption:
→ All 13.5M users have brand data
→ Can build affinity for everyone

Reality discovered:
→ Only 5,543,584 (41%) have brand data
→ 7,973,806 (59%) have NO brand
→ Called "blind users"
→ Cannot build direct affinity
