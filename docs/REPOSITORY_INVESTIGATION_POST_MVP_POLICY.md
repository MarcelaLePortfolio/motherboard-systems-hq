# Repository Investigation — Post-MVP Next-Steps Policy

Status: ACTIVE INVESTIGATION GUIDANCE

## Rule

Any repository investigation whose scope includes post-MVP roadmap, post-MVP priorities, remaining architecture, next capabilities, reliability improvements, or recommended next steps must consult:

`docs/POST_MVP_NEXT_STEPS.md`

before finalizing its recommendations.

## Required behavior

The investigation must:

1. Read the current repository evidence first.
2. Determine whether MVP completion is established, pending, or out of scope.
3. Read the canonical post-MVP registry.
4. Compare each registry candidate against current repository capability.
5. Exclude candidates already fully implemented.
6. Preserve candidates that remain relevant.
7. Explicitly identify dependencies, authority boundaries, and risks.
8. Keep proposed work distinct from authorized work.

## Current mandatory candidate

QA Recovery Agent:

`docs/architecture/QA_RECOVERY_AGENT.md`

The QA Recovery Agent should therefore automatically enter consideration whenever a repository investigation asks what should happen after MVP completion.

This policy does not authorize implementation.
