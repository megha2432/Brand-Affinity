# Extension Plan — Phase 3

## Current State After Phase 2
| Component | Status |
|-----------|--------|
| Signal weights | ✅ Data-proven (logistic regression) |
| Discount factor | ✅ 98.82% fill rate, 63.79% avg discount |
| V4 in CTR track | ✅ Biggest Phase 2 discovery (57.3%) |
| V5 excluded | ✅ Negative signal confirmed |
| Lambda decay | ⚠️ 0.015 hardcoded for all brands |
| Intent base weights | ⚠️ 0.10/0.30/0.45/0.60 hardcoded |
| Data window | ⚠️ 30 days only |
| FEL integration | ❌ Not yet done |

## Priority 1: 90-Day Data Window
Expected gain: +2-4% accuracy
- V5 windows → 0-30 days recent, 31-90 days older
- V3 captures repeat purchase patterns
- Time decay is more meaningful

## Priority 2: FEL Integration
Expected gain: +3-7% accuracy (biggest remaining)
intent_weight = base_weight × FEL_purchase_score
- Personalised weights per user instead of global
- Same action gets different weight for high vs low propensity users

## Priority 3: Brand Tier Aware Lambda
Expected gain: +1-3%
- Luxury (Chanel, Dior) → lambda=0.008 (90 day half-life)
- Premium (HUGO, LACOSTE) → lambda=0.015 (46 day half-life)
- Accessible (Adidas, Nike) → lambda=0.023 (30 day half-life)

## Priority 4: Session-Based Signal
- session_id column already exists in source table
- Multiple brand interactions in same session = stronger signal
- Focused session on one brand → weight boost

## Priority 5: Collaborative Filtering
- "Users like you also like..."
- Discover brand interest before user shows it
- Especially powerful for new/sparse users

## Expected Phase 3 Accuracy
| Improvement | Expected | Cumulative |
|-------------|---------|-----------|
| Phase 2 baseline | — | 80.82% |
| 90-day data | +2-4% | ~84% |
| FEL integration | +3-7% | ~89% |
| Brand tier lambda | +1-3% | ~91% |
| Session signal | +1-2% | ~92% |
| Collaborative filter | +2-4% | ~94% |
