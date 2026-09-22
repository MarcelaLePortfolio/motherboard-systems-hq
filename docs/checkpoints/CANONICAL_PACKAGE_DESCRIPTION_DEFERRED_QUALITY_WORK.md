# Canonical Package Description — Deferred Quality Work

## Status

DEFERRED_WORK=YES
IMPLEMENTATION_REQUIRED_NOW=NO
CURRENT_CANONICAL_VISIBILITY_RESTORATION_BLOCKED=NO
DISCOVERY_CLASS=VALIDATED_DOGFOOD_OBSERVATION

## Context

The Canonical Package visibility restoration has been functionally validated. Approved Canonical Packages are visible in the existing Approvals / Executive Inbox, remain distinct from pending Approval Requests, and are presented read-only.

During manual review of the first visible Canonical Package, two quality defects were observed in the Canonical Package description / interpretation content.

These defects do not invalidate Canonical Package persistence, approval, visibility, authority, or read-only presentation.

## Deferred Issue 1 — Repetitive Canonical Description

The Canonical Package description repeats substantially the same intent multiple times.

Observed behavior:

- successive interpretations of the user's request are accumulated;
- semantically redundant statements remain in the final description;
- the resulting Canonical Package description is materially longer than necessary.

Desired future behavior:

The Canonical Package should preserve the complete authoritative meaning of the approved interpretation while presenting that meaning concisely, without unnecessary semantic repetition.

This must not be solved by discarding provenance, approval lineage, evidence, or authoritative package semantics.

## Deferred Issue 2 — Historical Greeting Leaks Into Canonical Description

The Canonical Package description ends with an earlier Matilda greeting:

> Hello. I'm ready to assist you with the Motherboard Systems HQ project. How can I help today?

This greeting originated earlier in the conversation and is not part of the approved work intent.

Desired future behavior:

Irrelevant conversational material such as greetings should not appear in the finalized Canonical Package description merely because it exists in accumulated interpretation history.

Any future correction must preserve underlying evidence and lineage rather than deleting historical evidence from the system.

## Investigation Boundary

Future deferred-work investigation should determine where semantic accumulation becomes presentation content and identify the narrowest correction that:

- compacts redundant interpretation content;
- excludes irrelevant historical conversational material from Canonical Package description output;
- preserves source evidence and provenance;
- preserves Living Draft and Canonical Package lineage;
- preserves approval semantics;
- preserves authoritative Canonical Package content;
- does not silently rewrite approved historical records.

Do not assume whether the appropriate correction belongs in interpretation generation, Living Draft assembly, canonicalization, read-model projection, or presentation until investigated.

## Protected Boundaries

No deferred fix is pre-authorized.

The following remain protected:

- Canonical Package authority;
- approval semantics;
- Request Changes semantics;
- delegation;
- validation;
- envelope construction;
- execution;
- governance;
- provenance;
- evidence retention;
- historical lineage.

Approval remains distinct from delegation and execution.

## Deferred-Work Discovery Markers

DEFERRED_WORK_CATEGORY=CANONICAL_PACKAGE_CONTENT_QUALITY
DEFERRED_WORK_COMPONENT=MATILDA_CANONICAL_PACKAGE_DESCRIPTION
DEFERRED_WORK_ISSUE_1=REDUNDANT_INTERPRETATION_ACCUMULATION
DEFERRED_WORK_ISSUE_2=IRRELEVANT_HISTORICAL_GREETING_INCLUSION
DEFERRED_WORK_DISCOVERABLE=YES
DEFERRED_WORK_INVESTIGATION_REQUIRED=YES
DEFERRED_WORK_IMPLEMENTATION_AUTHORIZED=NO
PRIORITY=NON_BLOCKING
CURRENT_RESTORATION_STATUS=VALIDATED
