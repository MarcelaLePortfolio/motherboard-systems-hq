
# Phase 731 Stress Baseline Findings

## Scope

This record captures the first controlled stress run for the semantic trend engine.

No runtime, renderer, orchestration, persistence, task routing, or Preview contracts were modified.

## Tested Engine

- Script: `scripts/semantic-observability/generate-semantic-trend-analysis.sh`

- Harness: `phase731_stress_trend_engine.sh`

- Branch: `phase730-semantic-section-extraction`

- Baseline commit before findings record: `7202cce4`

## Controlled Cases

| Case | Scores | Trend | Micro | Variance | Confidence | Reliability | Direction |

|---|---:|---|---|---:|---:|---|---|

| stable flat | 160, 160, 160 | Stable | Flat | 0 | 100/100 | High | Strong stable system |

| gradual upward drift | 150, 155, 160 | Improving | Upward | 16 | 70/100 | Medium | Weak or uncertain signal |

| gradual downward drift | 160, 155, 150 | Degrading | Downward | 16 | 70/100 | Medium | Weak or uncertain signal |

| oscillation reversal | 160, 150, 160 | Stable | Oscillation | 22 | 45/100 | Low | Weak or uncertain signal |

| variance spike upward | 100, 160, 220 | Improving | Upward | 2400 | 60/100 | Medium | Weak or uncertain signal |

| variance spike downward | 220, 160, 100 | Degrading | Downward | 2400 | 60/100 | Medium | Weak or uncertain signal |

## Findings

1. Perfectly flat stability is correctly classified as high-confidence stability.

2. Gradual directional drift is detected, but reliability remains medium due to variance.

3. Oscillation is correctly penalized into low reliability.

4. Large variance spikes are currently not penalized enough; they remain medium reliability because macro and micro signals agree.

5. The next safe improvement is to add a high-volatility confidence penalty or reliability downgrade while preserving the observability-only corridor.

## Next Target

Add a bounded high-volatility confidence penalty so extreme variance cannot appear more reliable than gradual, lower-variance directional movement.

