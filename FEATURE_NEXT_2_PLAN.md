# Feature Next-2 Plan (from Stable v11.12 w/ Meta Docs)

Branch:
- feature/next-2-from-stable

Base:
- v11.15-stable-v11.12-with-meta-docs

Guardrails:
- No changes to server.mjs routing, port binding, or static mount behavior unless explicitly planned + tested + tagged.
- Every feature change must include a 60-second smoke test (GET / and GET /dashboard => 200).
- If we hit 3 consecutive failed attempts on a hypothesis, revert to v11.15 stable tag and regroup.

Pending: define the first concrete feature goal for next-2.
