.PHONY: help phase15-checks

help:
	@echo "Available targets:"
	@echo "  phase15-checks  Run Phase 15 confidence checks"

phase15-checks:
	@echo "== Running Phase 15 Confidence Checks =="
	@./scripts/phase15_run_checks.sh
