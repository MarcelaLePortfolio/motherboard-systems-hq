# Phase 487 — Git History Recovery Plan

## Observation
Working-tree cleanup has not resolved the dominant storage problem because `.git` remains the largest consumer.

## Goal
Confirm repository-history pressure before any dedicated history-reduction corridor.

## Immediate next step
Run a bounded assessment of:
- current `.git` size
- object and pack counts
- largest pack files

## Constraint
This step performs assessment only.
No history rewrite is performed here.
