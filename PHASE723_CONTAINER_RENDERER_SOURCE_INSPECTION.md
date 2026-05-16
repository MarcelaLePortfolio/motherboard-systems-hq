
# Phase 723 Container Renderer Source Inspection

## Objective

Determine whether the dashboard container is serving a stale copied renderer file or the current host source file.

## Reason

Dashboard restart succeeded, but served JS verification did not print expected Phase 723 strings.

This means the issue is likely one of the following:

1. the dashboard container is serving a stale copied asset

2. the public source directory is not mounted into the running container

3. the served JS path differs from the host source path

4. grep output was empty because the served file does not include the latest source

## Inspection Commands

- inspect renderer file inside dashboard container

- grep Phase 723 wrapper inside dashboard container

- grep Phase 723 sanitizer inside dashboard container

- grep visual marker inside dashboard container

- compare against host source grep

## Pass Criteria

The container source file should contain:

- `phase723RenderVisualArtifactPreviewCandidate`

- `phase723SanitizeVisualArtifactHtml`

- `visual-artifact:start`

## Interpretation

If the host file contains Phase 723 strings but the container file does not, rebuild or recreate the dashboard container.

If both contain Phase 723 strings but served curl does not, inspect Express static routing or alternate served asset path.

## Contract Preservation

This inspection does not modify:

- backend routes

- worker persistence

- retry contract

- SSE pipeline

- DB schema

- artifact preview route

- task polling

- Agent Pool refresh behavior

## Next Safe Step

Only proceed to browser validation after the container and served asset are confirmed current.

