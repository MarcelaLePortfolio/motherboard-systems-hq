# Patent-Readiness Development Protocol

## Status

This protocol is an internal engineering and evidence-preservation standard for Motherboard Systems HQ and future projects developed through the system.

It is not a determination that any feature, system, workflow, or project is patentable, and it is not a substitute for eventual patent counsel. Its purpose is to preserve evidence, authorship history, confidentiality boundaries, and technical specificity that may later be useful when patentability and inventorship are evaluated.

## Core Principle

Development should preserve:

1. human conception evidence;
2. technical implementation evidence;
3. chronological provenance;
4. confidentiality before intentional disclosure;
5. distinctions between human decisions and AI-assisted drafting or implementation;
6. failed approaches and technical alternatives when materially relevant;
7. evidence connecting conception, refinement, implementation, and validation.

No Git feature may claim or infer that following this protocol makes an invention patentable.

## Repository Confidentiality Boundary

Patent-sensitive repositories should remain private unless an explicit disclosure decision has been made.

Motherboard Systems HQ must not automatically:

- make a private repository public;
- publish patent-sensitive architecture;
- publish invention disclosures;
- publish internal design records;
- publish patent-readiness metadata;
- create public releases containing previously confidential inventive subject matter.

Repository visibility changes require explicit user authorization separate from ordinary commit or push authorization.

## Human Inventorship Evidence

For potentially inventive work, the repository should preserve evidence of the human contribution to conception.

The system must distinguish:

- user-originated objectives;
- user-originated architectural choices;
- user-originated constraints;
- user-selected alternatives;
- user corrections to proposed designs;
- user-defined technical mechanisms;
- user approval or adoption of mechanisms developed during collaboration;
- AI-generated suggestions;
- Cade implementation activity;
- validation and testing activity.

AI assistance must not be represented as human conception.

A Git author, committer, automation identity, or execution agent must not be treated as proof of patent inventorship.

## Invention Evidence Record

When work may contain patentable subject matter, Motherboard should support a private invention evidence record containing:

- evidence record ID;
- project ID;
- timestamp;
- related commit SHA;
- human contributor or contributors;
- problem being solved;
- prior system limitation;
- conceived technical mechanism;
- alternatives considered;
- reasons for selecting the mechanism;
- architectural boundaries;
- technical dependencies;
- expected technical effect;
- validation criteria;
- implementation status;
- validation results;
- AI assistance used;
- links to relevant internal commits or artifacts.

Evidence records should describe technical mechanisms rather than merely desired outcomes.

## Git Commit Provenance

Governed Cade commits should eventually record enough internal metadata to reconstruct the authorized technical change without unnecessarily placing confidential invention details in public-facing commit messages.

Minimum internal provenance should include:

- execution envelope ID;
- authorization ID;
- project ID;
- repository identity;
- branch;
- expected pre-commit HEAD;
- resulting commit SHA;
- approved file set;
- actual committed file set;
- validation result;
- Cade execution event ID;
- human authorization source.

Commit messages should remain technically useful but should not unnecessarily disclose confidential inventive concepts.

Detailed invention rationale belongs in private internal evidence records rather than automatically in commit messages.

## Commit Integrity Requirements

Cade's governed Git implementation must preserve:

- exact repository verification;
- exact branch verification;
- expected HEAD verification;
- approved-path-only staging;
- detection of unapproved tracked changes;
- prohibition on `git add .`;
- prohibition on force push;
- explicit commit authorization;
- explicit push authorization;
- commit and push as separate governed transitions;
- fail-closed behavior on repository drift;
- validation before commit;
- verification of committed file scope;
- verification of remote state after push;
- durable execution provenance.

Generic shell authority is not required and must not be introduced solely to support Git.

## Patent-Sensitive Commit Classification

Future governed commits should be capable of carrying a private internal classification:

- `ordinary`
- `potentially_inventive`
- `invention_evidence`
- `implementation_validation`
- `reduction_to_practice_candidate`
- `public_disclosure_candidate`

These classifications are evidence-management labels only.

They do not constitute legal patent determinations.

## Public Disclosure Gate

Any action that may expose potentially inventive subject matter outside controlled private access should be treated separately from ordinary Git push.

Examples include:

- changing repository visibility to public;
- publishing documentation;
- publishing source code;
- posting technical descriptions publicly;
- creating public demos that reveal implementation details;
- publishing releases;
- externally distributing architecture documents.

Motherboard should surface a disclosure warning before such an action when a project contains material classified as potentially inventive or invention evidence.

The warning must not decide legal consequences.

## AI-Assisted Development Record

Because Motherboard Systems HQ uses AI-assisted development, evidence should preserve the difference between:

- what the user conceived;
- what the user selected;
- what the user rejected;
- what the user materially modified;
- what an AI system suggested;
- what Cade implemented from an authorized specification.

The system should preserve enough context to reconstruct these distinctions later.

AI-generated text should not automatically be labeled as user conception.

## Failed Attempts

Failed implementation attempts should normally remain in repository history when they materially document the development path.

A failed attempt may provide useful evidence of:

- technical obstacles;
- rejected mechanisms;
- refinement of the conceived mechanism;
- experimental validation;
- why a later implementation differs.

Repository history must not be rewritten merely to create a cleaner invention narrative.

Secrets, credentials, accidental sensitive data, or legally required removals remain exceptions.

## Validation Evidence

For potentially inventive implementations, preserve:

- tests executed;
- test results;
- environment where validation occurred;
- expected behavior;
- actual behavior;
- relevant commit SHA;
- failure conditions;
- successful technical effect.

A successful commit alone must not be treated as proof that the mechanism works for its intended technical purpose.

## Current Cade Version-Control Project

The governed Cade Git capability currently under development must follow this protocol.

Its intended architecture remains:

- Cade owns governed engineering execution;
- commit and push are separate governed actions;
- repository identity is explicit;
- branch is explicit;
- expected HEAD is explicit;
- approved file scope is explicit;
- validation is explicit;
- generic shell authority remains disabled;
- force push remains prohibited;
- remote publication or repository visibility changes remain separately authorized.

The existing legacy Cade `git add .` / commit / push path must not be reactivated as the production implementation.

## Future Project Default

New Motherboard-managed projects should default to:

- private repository visibility where supported;
- provenance-preserving commits;
- no automatic history rewriting;
- no automatic public release;
- human/AI contribution distinction;
- optional invention evidence records;
- disclosure-sensitive release gating.

These defaults preserve optionality for later IP review without asserting that the project contains patentable subject matter.

## Legal Review Checkpoint

When practical, obtain qualified patent counsel before:

- filing a patent application;
- deciding inventorship;
- relying on a particular disclosure date;
- intentionally making patent-sensitive work public;
- deciding foreign filing strategy;
- asserting that a feature is patentable;
- asserting that an implementation constitutes legal reduction to practice.

Development does not need to stop while awaiting counsel if the project can remain private and evidence-preserving.

## Non-Guarantee

No repository workflow, Git configuration, provenance system, private-repository setting, invention record, commit timestamp, or AI-assistance log can guarantee patentability.

This protocol exists to preserve evidence and options while development continues.
