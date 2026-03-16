# Brand-Affinity


## Overview
End-to-end brand affinity scoring pipeline for Breuninger.
Scores every user × brand pair and ranks brands by predicted engagement
and purchase probability.

## Source Table
zeotap-dev-datascience.FEL_eu_west3.event_store_30_days_real_partition
- 372M rows, 30 days (Jan 24 – Feb 23 2026)
- 5.5M users, 1,721 brands

## Output Tables
| Table | Rows | Description |
|-------|------|-------------|
| brand_step0_train_v2 | 100M | Clean browsing events + discount |
| brand_step0_holdout_v2 | 1.2M | Purchase events (validation only) |
| brand_step4_ctr_affinity_v2 | 20.7M | CTR probability per user-brand |
| brand_step7_conv_affinity_v2 | 20.7M | Conv probability per user-brand |
| brand_step8_affinity_final_v2 | 20.7M | Unified final table |
| brand_step9_user_summary_v2 | 5.5M | One row per user |
| brand_affinity_simple_view | 20.7M | Human-readable final view |

## Accuracy
| Phase | Conv Accuracy | Notes |
|-------|--------------|-------|
| Phase 1 | 79.38% | Equal weights, no discount factor |
| Phase 2 | 80.82% | Proven weights + discount factor (+1.52%) |

## Quick Start
Run steps in order: data_prep → scoring → affinity
Each folder has query.sql, validate_before.sql, validate_after.sql
