# Intent Lifecycle Architecture

Status: Architectural Invariant

## Purpose

This document defines the complete lifecycle of user intent from conversation through execution authorization.

Each artifact has exactly one responsibility.

No artifact duplicates another artifact's responsibility.

---

# Systems of Record

## Conversation

The Conversation is the authoritative record of user intent.

It is append-only.

It preserves:

- user requests
- executive revisions
- Matilda interpretation
- clarification dialogue
- historical context

The conversation is never rewritten.

---

## Living Draft

The Living Draft is the authoritative record of the current interpretation of the conversation.

It is mutable.

It evolves as the conversation evolves.

It represents exactly one current interpretation.

Previous revisions remain recoverable as history.

---

## Approval Request

Approval Requests are executive read models.

They are projections.

They are not systems of record.

They exist only to present the current Living Draft for executive review.

Approval Requests contain no unique authority beyond their projection.

---

## Canonical Package

A Canonical Package is the authoritative record of approved interpretation.

It is immutable.

It represents executive authorization.

Future changes require amendment through a new governance corridor rather than rewriting the Canonical Package.

---

# Intent Flow

User Conversation

↓

Interpretation Evidence

↓

Matilda Interpretation

↓

Living Draft

↓

Approval Request Projection

↓

Executive Decision

Approve

↓

Canonical Package

or

Request Changes

↓

Conversation

↓

Matilda Interpretation

↓

Updated Living Draft

↓

Updated Approval Request Projection

---

# Authority Ownership

Conversation owns:

- intent history

Living Draft owns:

- current interpretation

Approval Request owns:

- executive presentation

Canonical Package owns:

- approved interpretation

No artifact owns responsibilities belonging to another artifact.

---

# Mutation Rules

Conversation

- append only

Living Draft

- current interpretation may evolve

Approval Request

- regenerated through projection

Canonical Package

- immutable

---

# Interpretation Rule

Only Matilda interprets intent.

No other subsystem may reinterpret user intent.

Executive feedback becomes conversation evidence.

Matilda determines how that evidence affects the Living Draft.

---

# Projection Rule

Approval Requests are projections.

Executive Inbox is a projection.

Future executive surfaces are projections.

The mutable authority remains the Living Draft.

---

# Architectural Invariant

The Conversation is the system of record for intent.

The Living Draft is the system of record for the current interpretation of that intent.

Approval Requests are executive projections.

Canonical Packages are immutable records of approved interpretation.

Every governance workflow composes these responsibilities rather than duplicating them.
