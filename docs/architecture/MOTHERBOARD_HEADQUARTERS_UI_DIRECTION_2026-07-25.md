# Motherboard Systems HQ — Headquarters UI Direction

Date: 2026-07-25
Status: Approved architectural direction

## Product North Star

Motherboard Systems HQ is a headquarters on a screen.

The experience should feel like entering and directing an organization, not opening a chatbot or automation tool.

Design question:

> If AI employees actually existed, what would their headquarters look like?

The UI should feel operational, calm, trustworthy, and alive.

---

## Mission Control

Mission Control replaces "Dashboard."

Mission Control answers one executive question:

> Where is my mission?

It is not a metrics dashboard.

It is the command-and-visibility center for the organization's active mission.

Mission Control begins only after operationalization.

Conversation
→ Matilda interpretation
→ Living Draft
→ Package
→ Governance Validation
→ Envelope
→ Department Assignment
→ Execution
→ Outcome Review
→ Complete

Mission Control must never fabricate runtime state.

---

## Headquarters Information Architecture

The application is organized around places, not software features.

Approved sidebar direction:

Mission Control

CONVERSATIONS
    Retrieval Runtime
    UI Shell
    Mobile App
    ...

DEPARTMENTS
    Engineering
    Operations
    Atlas
    Effie
    Cade

Executive Review

Operations

Archives

Media Library

Settings

Collections (Conversations, Departments) organize destinations.

They are not themselves required workspaces.

---

## Conversations

Conversation threads appear directly in the sidebar.

No dedicated Conversations page is required.

Selecting a thread opens that conversation immediately.

Conversation list:

- project scoped
- scrollable
- durable
- future folders/search
- future status indicators

Remove the redundant project card from the sidebar.

The project selector already exists in the persistent header.

---

## Departments

Departments are stable organizational abstractions.

Initial implementation should provide placeholder workspaces only.

No fabricated activity.

No simulated assignments.

---

## Mission Control Layout

Representative hierarchy:

1. Current Mission
2. Mission Status
3. Latest Event
4. Next Step
5. Mission Pipeline
6. Package Details
7. Active Department / Owner
8. System Overview

The generated Mission Control mockups establish the intended layout and visual hierarchy, not final wording.

---

## Executive Question Principle

Every workspace answers one executive question.

Mission Control
→ Where is my mission?

Conversation
→ What are we discussing?

Engineering
→ What is Engineering working on?

Operations
→ What is currently executing?

Executive Review
→ What needs my approval?

Archives
→ What has already happened?

Media Library
→ What organizational media exists?

---

## Visual Direction

Maintain:

- calm hierarchy
- restrained styling
- generous whitespace
- operational feeling
- minimal decoration

Do not imitate generic SaaS dashboards.

The UI should feel like headquarters.

---

## Sidebar Corridor

Next implementation slice:

✓ Rename Dashboard → Mission Control

✓ Remove redundant sidebar project card

✓ Sidebar conversations

✓ Scrollable thread list

✓ Departments section

✓ Engineering placeholder

✓ Operations department placeholder

✓ Atlas placeholder

✓ Effie placeholder

✓ Cade placeholder

✓ Executive Review placeholder

✓ Operations placeholder

✓ Archives placeholder

✓ Media Library placeholder

✓ Settings

No runtime wiring yet.

No fabricated state.

---

## Following Corridor

Once the sidebar is stable:

Wire Mission Control to authoritative runtime state.

Mission Control should visualize real organizational activity rather than placeholder data.
