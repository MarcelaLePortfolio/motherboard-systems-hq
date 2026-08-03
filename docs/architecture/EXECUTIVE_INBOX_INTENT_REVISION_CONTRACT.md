# Executive Inbox Intent Revision Contract

Status: Architectural Invariant

## Purpose

This contract defines how **Request Changes** behaves when an executive reviews a Reconciled Interpretation Summary in the Executive Inbox.

Request Changes exists to correct or refine Matilda's interpretation of the user's intent. It is **not** a rejection workflow, a silent backend mutation, or the creation of a separate concept.

---

# Living Draft Continuity

A Living Draft represents the current interpretation of one continuous intent.

Submitting Request Changes does **not** create a new Living Draft.

Instead it updates the current Living Draft while preserving:

- project identity
- conversation identity
- lineage identity
- package identity

Previous revisions must remain recoverable as history, but there is always one current Living Draft representing the active interpretation.

A separate Living Draft should only be created when the user intentionally separates the work into a distinct objective.

---

# Preservation Principle

Matilda must preserve everything the user did not modify unless the requested revision makes existing interpretation inconsistent.

Therefore:

- revised meaning is reconsidered
- unchanged meaning remains authoritative
- dependent interpretation is reevaluated only when necessary
- unrelated interpretation must not be discarded
- architectural conflicts must be surfaced rather than silently resolved

The default assumption is continuity, not regeneration.

---

# Conversation Authority

The Executive Inbox initiates revisions.

The originating Matilda conversation remains the authoritative interpretation surface.

When Request Changes is submitted:

1. Executive feedback is persisted.
2. The feedback is inserted into the originating conversation as a new user message.
3. The user can immediately see their submitted revision inside the conversation.
4. Matilda interprets the revision.
5. Matilda replies.

Only after sufficient intent is resolved may the Living Draft update.

---

# Why Feedback Appears In The Conversation

Executive feedback is intentionally visible inside the conversation because revisions are not always mechanically applicable.

Sometimes the requested revision introduces architectural implications requiring discussion.

Example:

Executive:

> Keep everything else the same, but move image generation local.

Matilda may respond:

> That conflicts with the existing video pipeline assumptions.
>
> Would you also like video generation to become local?

The conversation therefore becomes the place where interpretation is resolved.

The Executive Inbox remains the place where revision is initiated.

---

# Living Draft Update Rules

If the requested revision is immediately compatible:

Executive Inbox
→ Request Changes
→ Feedback inserted into conversation
→ Matilda interprets
→ Living Draft updated
→ Executive Inbox refreshes

If clarification is required:

Executive Inbox
→ Request Changes
→ Feedback inserted into conversation
→ Matilda asks questions
→ User responds
→ Living Draft updated after clarification

The Living Draft must never mutate silently.

---

# Architectural Boundary

The Executive Inbox may initiate interpretation changes.

Only Matilda may interpret intent.

The Executive Inbox must never independently reinterpret, rewrite, or mutate intent outside the originating conversation.

---

# Architectural Invariant

The stable rule is:

> Executive feedback becomes part of the originating conversation because the conversation—not the Executive Inbox—is the authoritative location where intent is interpreted. A Living Draft evolves through that conversation while preserving all unaffected meaning unless the requested revision creates an architectural inconsistency.
