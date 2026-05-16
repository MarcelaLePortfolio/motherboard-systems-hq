
# Phase 723 Inactive Sanitizer Helper

## Objective

Add a minimal inactive sanitizer helper before any visual artifact rendering activation.

## Changed File

`public/js/phase530_visible_panels_bridge.js`

## Added Helper

`phase723SanitizeVisualArtifactHtml(html)`

## Current Activation State

The sanitizer helper is inactive.

It is not wired into:

- Preview modal rendering

- markdown fallback rendering

- semantic rendering

- artifact preview fetch handling

- worker persistence

## Sanitizer Scope

The helper removes or neutralizes:

- script blocks

- style blocks

- iframe blocks

- object blocks

- embed tags

- link tags

- meta tags

- inline event handlers

- javascript href/src values

## Preservation Notes

This commit does not activate embedded visual rendering.

The existing render path remains:

`phase719RenderMarkdownArtifactPreview(data.content)`

The existing semantic renderer remains:

`phase719RenderArtifactVisualCard(markdown)`

The existing final injection remains unchanged:

`body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content)`

## Validation

Syntax validation was run with:

`node --check public/js/phase530_visible_panels_bridge.js`

## Next Safe Step

Add an inactive visual renderer wrapper helper that combines:

- extraction helper

- sanitizer helper

- markdown fallback preservation

Do not connect it to the live Preview path until a separate activation checkpoint.

