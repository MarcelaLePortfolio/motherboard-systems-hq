# Executive Inbox Presentation Specification

## Objective

The Approvals workspace should not resemble a dashboard.

It should resemble an executive email client.

The primary cognitive model is:

"I have decisions waiting."

—not—

"I am viewing approval data."

---

# Layout

The workspace consists of only two primary regions.

┌──────────────────────────────────────────────────────────────┐
│ Executive Inbox                                 Refresh      │
├──────────────────────┬───────────────────────────────────────┤
│ Pending Decisions    │ Executive Briefing                    │
│                      │                                       │
│ decision             │ currently selected decision           │
│ decision             │                                       │
│ decision             │                                       │
│ decision             │                                       │
│ decision             │                                       │
│                      │                                       │
└──────────────────────┴───────────────────────────────────────┘

No additional cards.

No stacked sections.

No dashboard tiles.

---

# Left Column

The left column behaves exactly like an inbox.

Every row is a pending executive decision.

Each row contains only:

• decision title

• small status badge

• timestamp

• one-line summary

Nothing else.

Selecting a row updates only the reading pane.

The page never navigates.

---

# Right Column

The right column behaves exactly like an email preview.

It contains the executive briefing.

Recommended order:

Executive Question

↓

Requested Outcome

↓

Why approval is required

↓

Current State

↓

Proposed State

↓

Scope

↓

Constraints

↓

Supporting Evidence

↓

Technical Details (collapsed)

---

# Header

Current:

Executive Inbox

Approvals

Decisions waiting for executive attention.

Preferred:

Executive Inbox

Pending Executive Decisions

Refresh

No large explanatory paragraphs.

---

# Read-only Messaging

Do NOT dominate the page with read-only warnings.

Instead use one subtle banner.

Example:

Preview Mode

Decision controls will appear in a future corridor.

---

# Empty State

Instead of

"There are no Approval Requests"

Display

Your Executive Inbox is clear.

No decisions currently require executive authority.

---

# Loading State

Loading executive inbox...

---

# Error State

Unable to reach the Executive Inbox.

Retry

Avoid exposing API terminology such as

Approval Request API returned 404

to the executive UI.

Technical diagnostics belong elsewhere.

---

# Future Decision Controls

Reserve space beneath the briefing for

Approve

Request Changes

Reject

Execute

These remain disabled until their corridors are authorized.

---

# Visual Priority

Highest visual weight

1 Executive briefing

2 Pending inbox

3 Refresh

Lowest priority

technical IDs

read-only notes

metadata

