
# Render-Native Payload Sandbox

Status: Phase 736 continuation  

Mode: sandbox-first, non-live-preview mutation

## Purpose

Create deterministic render-native payload structures before any future live Preview renderer integration.

## Rules

- No live Preview renderer mutation.

- No speculative renderer interception.

- No prompt-only rendering assumptions.

- Payload structures must be deterministic.

- Sandbox validation must precede integration.

- Matilda approval remains required before execution mutation.

## Initial Target

Define and validate a render-native scene payload outside the live Preview corridor.

## Required Payload Shape

A render-native payload must include:

- schema version

- artifact type

- scene root

- layout mode

- visual nodes

- deterministic text content

- validation metadata

## Next Step

Create a sandbox payload schema and sample payload emitter.

