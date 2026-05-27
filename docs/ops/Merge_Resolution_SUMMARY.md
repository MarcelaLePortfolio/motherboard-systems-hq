/* eslint-disable import/no-commonjs */
# Merge Resolution — cade-hardening → main

Applied strategy:
- Ours (main):
  - memory/agent_chain_state.json
  - ui/dashboard/public/index.html
- Theirs (cade-hardening):
  - package.json
  - package-lock.json
  - scripts/_local/agent-runtime/launch-cade.ts
  - scripts/_local/agent-runtime/memory/agent_chain_state.json
  - scripts/_local/agent-runtime/utils/cade_task_processor.ts

Rationale:
- Preserve active runtime state and dashboard index from main.
- Adopt incoming code and dependency updates from cade-hardening.

Next:
- Run JSON state tests to validate read/write after merge.
