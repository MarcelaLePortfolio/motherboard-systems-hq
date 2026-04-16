#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

pkill -f "phase487_reconcile_and_push.sh" 2>/dev/null || true
pkill -f "git stash push -u" 2>/dev/null || true

rm -f .git/index.lock
find .git -name "*.lock" -delete 2>/dev/null || true

rm -f docs/PHASE_490_OPERATOR_HEIGHT_CHECKPOINT_SEARCH.txt
rm -f docs/PHASE_490_OPERATOR_HEIGHT_CHECKPOINT_SEARCH.txt.gz

git restore \
  docs/phase487_served_dashboard_snapshot_20260415_223300.html \
  public/dashboard_body_q1_probe.html \
  public/dashboard_body_top_half_probe.html \
  public/dashboard_recomposed_from_stable_quarters_probe.html \
  public/index.html \
  scripts/_local/post_restart_service_verification.sh \
  scripts/phase487_rank_exact_boundary_candidates.sh \
  server.mjs || true

git restore \
  docs/phase464_3_operator_guidance_tab_reentry_scan.txt \
  docs/phase464_x_phase456_baseline_emitter_candidates.txt \
  docs/phase473_2_trace_actual_dashboard_html_source.txt \
  docs/phase487_rebuild_dashboard_for_confidence_fix_20260415_215817.txt || true

rm -f \
  docs/phase487_dashboard_guidance_consumers.txt \
  docs/phase487_guidance_owner_extract.txt \
  docs/phase487_guidance_signal_hunt.txt \
  docs/phase487_runtime_guidance_bindings.txt \
  docs/phase_487_operator_guidance_repo_probe.md \
  docs/system_health_deep_check_20260415_143634.txt \
  docs/system_health_deep_check_20260415_143700.txt \
  docs/system_health_deep_check_20260415_143922.txt \
  docs/system_health_deep_check_20260415_143953.txt \
  scripts/_local/phase490_search_operator_height_checkpoint.sh \
  scripts/_local/system_health_deep_check.sh \
  scripts/phase487_apply_exact_visible_confidence_patch.sh \
  scripts/phase487_force_confidence_display_normalization.sh \
  scripts/phase487_operator_guidance_repo_probe.sh \
  scripts/phase487_patch_operator_guidance_card.sh \
  scripts/phase487_patch_recommended_display_layer_file.sh \
  scripts/phase487_patch_remaining_confidence_display.sh \
  scripts/phase487_read_served_confidence_verification_verdict.sh || true

git fetch origin phase119-dashboard-cognition-contract
git rebase origin/phase119-dashboard-cognition-contract
git push origin HEAD:phase119-dashboard-cognition-contract

git status --short
