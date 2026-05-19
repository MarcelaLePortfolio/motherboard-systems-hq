
# Phase 733 Preview Transport Normalization

## Change

Added preview-only escaped transport newline normalization inside the artifact preview renderer path.

## Scope

Frontend renderer only.

## Purpose

Prevent literal escaped newline sequences such as `\n\n` from appearing in artifact preview surfaces.

## Boundary

This does not:

- change routes

- change database state

- activate execution bridge

- alter artifact lifecycle authority

- grant Matilda execution authority

- mutate persistence contracts

## Target File

public/js/phase530_visible_panels_bridge.js

## Expected Result

Artifact previews should render escaped transport text with readable spacing before semantic section extraction and visual block rendering.

