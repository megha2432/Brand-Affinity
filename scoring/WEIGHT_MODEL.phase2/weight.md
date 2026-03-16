weights.md
# Final Proven Weights

## CTR Track
V4 (Funnel) = 57.3%  ← BIGGEST — was missing from Phase 1!
V1 (Recency) = 38.4%
V6 (Breadth) = 5.0%
V5 (Velocity) = 0% (excluded — negative signal)

Formula: ctr_raw = (0.5729 × v4_norm) + (0.3839 × v1_norm) + (0.0503 × v6_norm)

## Conv Track
V3 (RFM) = 82.9%  ← completely dominates
V4 (Funnel) = 17.1%

Formula: conv_raw = (0.8287 × v3_norm) + (0.1713 × v4_norm)

## Why V1/V5/V6 Negative in Full Model?
When V3 is present: browsing signals appear negative.
Reason: user who already bought (high V3) and browses a lot
is in "exploration" mode — not about to buy again.
For CTR track (no V3): V1, V4, V6 are all positive ✅

## Accuracy After Weights
Phase 1 (equal weights): 79.38%
Phase 2 (proven weights): 80.82% (+1.52% ✅)

## When to Retrain
- New 90-day data window available
- FEL scores integrated
- Accuracy drops below 78%
