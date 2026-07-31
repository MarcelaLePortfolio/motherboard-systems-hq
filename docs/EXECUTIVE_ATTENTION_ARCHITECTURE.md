# Executive Attention Architecture

## Purpose

The notification bell is the executive-facing routing layer for new matters requiring executive awareness.

It does not own conversations, packages, missions, or department issues. Every notification points to the authoritative home of the object it represents.

---

# Authoritative Destinations

| Notification Type | Destination |
|-------------------|-------------|
| Mission-related question or decision | Matilda Chat (scrolled to the relevant message) |
| Package Preview ready | Package Inbox (opens the preview) |
| Canonical Package ready | Package Inbox (opens the package) |
| Mission status or outcome | Mission Control |
| Department issue | Responsible department workspace |
| System issue | Responsible operational workspace |

---

# Notification Eligibility

A notification is created whenever something new enters the executive's awareness.

Examples include:

- Package Preview ready for review
- Canonical Package ready for delegation
- Mission requires an executive decision
- Department requires executive awareness
- Important system issue
- Significant mission outcome

Routine internal processing does not create notifications.

Artifacts generate notifications only when they become relevant to the executive—not while they are still being internally prepared.

---

# Mission vs Organization

Mission-related attention appears in both places:

- Matilda Chat (where the conversation happens)
- Notification Bell (so the executive notices it immediately)

Clicking the notification routes directly to the relevant point in the conversation.

Organization-level events generally appear only in the bell and route to their authoritative workspace.

Examples:

- Security
- Engineering
- Atlas
- Effie
- Legal
- Research

A system issue may also appear in Matilda Chat only if it directly blocks the active mission.

---

# Notification States

The notification system intentionally has only two states.

## Unread

The executive has not yet viewed the notification.

Unread styling should be visually prominent.

Examples:

- bold title
- accent background
- unread indicator
- contributes to bell badge count

---

## Read

The executive has opened the notification.

Read notifications remain in the notification list but use quieter styling.

Examples:

- normal text weight
- neutral background
- no unread indicator
- no longer contributes to the unread badge

Reading a notification does **not** imply that the underlying matter has been completed.

Completion belongs to the authoritative destination.

Examples:

- Package Inbox determines whether a package still awaits review.
- Mission Control determines mission state.
- Departments determine operational status.
- Matilda Chat contains the ongoing conversation.

The bell never becomes a second workflow manager.

---

# Bell Badge

The bell badge represents only the number of unread notifications.

It does not represent:

- unresolved packages
- outstanding approvals
- active missions
- department workload

Those concepts already have authoritative homes elsewhere in the system.

---

# Notification Routing

Notifications never own content.

They simply route the executive to the authoritative location.

Examples:

Mission question

Bell

↓

Matilda Chat

---

Package Preview

Bell

↓

Package Inbox

---

Security alert

Bell

↓

Security Department

---

Engineering recommendation

Bell

↓

Engineering Department

---

Atlas finding

Bell

↓

Atlas

---

# Executive Attention Item

Each notification is backed by an Executive Attention Item.

Suggested runtime fields:

- attention_id
- origin_type
- origin_id
- title
- summary
- category
- priority
- destination_type
- destination_id
- deep_link
- read_at
- created_at
- updated_at

Notice there is intentionally no "resolved" state.

The notification references the authoritative object rather than attempting to duplicate its lifecycle.

---

# Core Principle

The bell answers one question:

> "What is new that I should be aware of?"

The destination answers:

> "What is it, and what should I do about it?"

Unread styling communicates novelty.

Read styling communicates that the executive has already seen the notification.

The authoritative destination remains responsible for every workflow, lifecycle, and completion state.
