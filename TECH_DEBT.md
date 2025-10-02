
These files were excluded from the TypeScript build to unblock Cade/Matilda integration.  
They still need cleanup and fixes before we can fully rely on them.

- db/task-db.backup.ts → duplicate imports/exports, invalid references
- db/task-db.ts → untyped params (uuid, agent, status, etc.)

- mirror/agent.ts → depends on missing `gizmo/` engine

- scripts/_local/agent-runtime/launch-cade.ts → imports non-existent `cade.mts.js`
- scripts/_local/utils/createAgentRuntime.ts → imports missing `types.js`

- scripts/agents/cade.mts → calls `callOllama` (not defined)
- scripts/agents/dispatch-queued-task.ts → `nextTask` inferred as unknown
- scripts/agents/effie.ts → payloadSchemas incomplete
- scripts/agents/matilda.ts → type mismatches (wrong args, null vs string, extra props)
- scripts/agents/utils/payload-schemas.ts → missing schemas for `delete file`, `run task file`
- scripts/agents/utils/reflect.ts → needs ES2023 lib for `findLast`, missing param types

- scripts/test-matilda-maintenance.ts → imports `handleMatildaMessage` (not exported)
- scripts/test-matilda-selfheal.ts → same
- scripts/test-matilda.ts → same
- scripts/test/create-test-task.ts → imports `queueTask` (not exported)

1. Prioritize database fixes (`db/task-db.ts`) since other agents depend on them.
2. Replace `.mts` files or port into `.ts` equivalents.
3. Incrementally re-include files into `tsconfig.json` as they’re fixed.
