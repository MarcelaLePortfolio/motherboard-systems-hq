#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
export NODE_ENV="${NODE_ENV:-development}"
node server/worker/phase26_task_worker.mjs
