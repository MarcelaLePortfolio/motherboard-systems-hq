# Draft Provisional Patent Claims – Motherboard Systems HQ

**Claim 1**: A method for translating natural language instructions into discrete executable steps via a local agent-based instruction compiler.

**Claim 2**: A system comprising:
- A compiler agent for decomposition of abstract input
- A prioritization agent for queuing actionable steps
- A task execution engine (TEE-1) for local file and shell operations
- A memory engine using SQLite for persistent logging and recall
where all components operate within a local environment.

**Claim 3**: The use of a version-pinned, open-source local language model to dynamically interpret vague commands, paired with execution guardrails filtering for unwanted ideological content prior to action.

**Claim 4**: A modular filtering mechanism integrated into the task execution engine that allows the user to define, update, or bypass ideological guardrails as needed — including logging of blocked outputs for audit and override.

**Claim 5**: A hybrid execution pipeline wherein TEE-1 first attempts known logic and, failing that, queries a local LLM whose output is parsed, filtered, logged, and optionally executed — all without network dependency.

Additional claims pending UI layer, remote access gateway, and modular scheduler.
