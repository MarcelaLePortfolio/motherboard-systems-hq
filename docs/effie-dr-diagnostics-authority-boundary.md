
# Effie Authority Boundary Candidate

Title: Disaster Recovery Diagnostic Attribution

Status: Candidate Responsibility

Date: 2026-06-21

## Context

During governance Package runtime validation, the Disaster Recovery system correctly detected failure and returned a non-zero exit code.

The root cause was not surfaced by the top-level DR command.

Manual investigation was required.

## Architectural Observation

Failure detection and failure attribution are separate capabilities.

A recovery system may correctly detect failure while still requiring manual diagnosis.

## Candidate Effie Responsibility

Effie should become the authoritative operational diagnostics agent for:

- backup failures

- DR failures

- retention failures

- synchronization failures

- storage exhaustion

- backup integrity failures

- recovery workflow failures

## Expected Capability

Given a failed DR run, Effie should:

- identify the failing stage

- identify the failing command

- identify the probable root cause

- identify affected artifacts

- recommend the safest recovery path

- distinguish operational failures from architectural failures

## Non-Authority

Effie may diagnose.

Effie does not automatically modify recovery systems unless explicitly authorized.

## Relationship To Existing Architecture

Atlas:

- roadmap authority

- dependency authority

- scope authority

Effie:

- operational visibility authority

- backup authority

- recovery authority

- diagnostic attribution authority

## Status

Candidate future responsibility.

Not yet implemented.

