# Delegation Workspace — Corridor 1 Implementation Ready

Milestone: Executive Mission Control
Phase: Delegation Workspace
Corridor: Request Changes Persistence
Status: READY_BOUNDED
Readiness commit: 52f4bbce
Implementation authorized: NO
Implementation started: NO

Verified identity path:
- Approval Request read model exposes project_id and conversation_id.
- Approval Request repository resolves project_id and conversation_id from authoritative persistence.
- Approval Request identity is derived from the pending Living Draft identity.
- Server can resolve the originating conversation without trusting client-supplied runtime identities.

Verified shared workflow:
- Request Changes must call runMatildaConversationWorkflow.
- Executive feedback becomes the workflow message.
- Project and conversation identities are server-resolved.
- Existing workflow owns IEL persistence, conversation-turn persistence, and Living Draft updates.
- Active conversation must remain unchanged.

Authority boundaries:
- No Approval Request mutation.
- No Canonical Package mutation.
- No delegation mutation.
- No validation authorization.
- No envelope authorization.
- No execution authorization.
- No new semantic authority.
- No new persistence layer.

Bounded implementation scope:
- Add a thin Request Changes orchestration route.
- Accept approval_request_id and feedback only.
- Resolve authoritative runtime identities server-side.
- Fail closed on unknown/non-pending approval requests, missing originating conversation, or empty feedback.
- Connect the existing Executive Inbox Request Changes control to the new route.

Next action: Await explicit implementation authorization.
