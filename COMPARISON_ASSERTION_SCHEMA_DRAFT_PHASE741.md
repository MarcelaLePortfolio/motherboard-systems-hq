
# Comparison Assertion Schema Draft — Phase 741

Status: DRAFT / PLANNING-ONLY / NON-AUTHORITATIVE

## Purpose

Define a deterministic structure for comparing:

- current artifact state

- intended artifact state

- semantic inspection findings

- Preview/Diff evidence

without granting renderer authority or execution authority.

## Core Principle

Assertions describe comparison evidence.

Assertions do not execute mutations.

## Proposed Assertion Structure

    {

      "assertion_id": "string",

      "assertion_type": "string",

      "current_state_reference": "string",

      "intended_state_reference": "string",

      "comparison_result": "match | mismatch | ambiguous",

      "evidence_chain": [],

      "semantic_observations": [],

      "ambiguity_flags": [],

      "safety_flags": [],

      "non_authoritative": true

    }

## Assertion Types

Allowed assertion categories:

- artifact-structure-comparison

- semantic-alignment-comparison

- preview-diff-consistency

- snapshot-consistency

- reconciliation-readiness

- rollback-readiness

- ambiguity-detection

## Explicit Non-Authority Rule

Assertions must never become:

- renderer commands

- execution commands

- worker instructions

- orchestration instructions

- mutation instructions

- approval artifacts

## Allowed Inputs

Assertions may consume:

- artifact snapshots

- semantic inspection observations

- comparison references

- validation evidence

- ambiguity classifications

- safety classifications

## Disallowed Inputs

Assertions must not consume:

- runtime mutation requests

- filesystem mutation requests

- database mutation requests

- PM2 orchestration requests

- Docker orchestration requests

- hidden worker execution routes

## Required Validation Discipline

Future assertion systems must require:

- deterministic evidence references

- reproducible comparison inputs

- rollback-safe inspection

- explicit ambiguity handling

- non-authoritative classification

## Future Corridor Requirement

Any future implementation beyond planning requires:

- evidence-backed approval

- rollback checkpoint

- renderer-safe verification

- Preview-safe verification

- runtime-safe verification

