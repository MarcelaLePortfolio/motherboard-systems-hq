#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

./scripts/validate-corridor-5-project-isolation-implementation.sh
