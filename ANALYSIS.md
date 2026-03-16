# Analysis & Findings

## Phase 1 Findings

### Data Quality
| Metric | Value |
|--------|-------|
| Total raw events | 372M rows |
| Brand fill rate | 34.38% |
| Distinct brands | 1,721 |
| Distinct users | 5.5M |
| Bot users removed | 12,761 (>1000 events) |

### Event Distribution
| Event | Count | Brand Fill% |
|-------|-------|-------------|
| product_view | 74.2M | 100% |
| view_cart | 46.9M | 97% |
| add_to_cart | 4.1M | 100% |
| add_to_wishlist | 3.1M | 100% |
| purchase | 1.3M | 100% |

### Phase 1 Accuracy
| Metric | Value |
|--------|-------|
| Conv accuracy | 83.82% (original) / 79.38% (revalidated) |
| CTR accuracy | 58.07% |
| Aligned accuracy | 89.40% |

---

## Phase 2 Findings

### Finding 1: Heavy Discount Retailer
- Average discount: 63.79% across all events
- 58% of interactions = discounted items
- 26% of interactions = items >70% off
- add_to_wishlist has HIGHEST discount avg (70.39%)
  → users mostly wishlist items when on sale
- Intent weight reduction after adjustment: 31.7%
  (avg base: 0.1821 → avg adjusted: 0.1244)

### Finding 2: V4 is #1 CTR Signal (surprise!)
- V4 (Funnel Depth) was NOT in CTR track in Phase 1
- Model proved V4 = 57.3% of CTR prediction
- Why: user who added to cart is more likely to
  engage again than one who just viewed recently

### Finding 3: V5 Excluded from CTR
- V5 weight = negative → excluded completely
- Valentine's Day bias in Feb data confirmed
- Growing interest does not predict next click
- Re-evaluate when 90-day data available

### Finding 4: V3 Dominates Conv at 82.9%
- Phase 1 assumed V3=50%, V4=50%
- Data proves V3=82.9%, V4=17.1%
- "Best predictor of future purchase = past purchase"

### Finding 5: Discount Signals Are Negative
- avg_discount_pct weight = negative
- Sale hunters are LESS likely to buy next time
- Need different campaign strategy for sale buyers

### Overfitting Checks
| Check | Result |
|-------|--------|
| Class imbalance | ✅ Fixed with 27x weight (96.48% not-purchased) |
| Data leakage (V3) | ✅ Confirmed, V3 excluded from CTR model |
| User-level CV split | ✅ Weights stable (diff < 0.01 per signal) |

### Final Proven Weights
CTR Track: V4=57.3%, V1=38.4%, V6=5.0%, V5=0% (excluded)
Conv Track: V3=82.9%, V4=17.1%

### Accuracy
Phase 1 → 79.38% | Phase 2 → 80.82% (+1.52% ✅)
5,170 additional users correctly targeted
