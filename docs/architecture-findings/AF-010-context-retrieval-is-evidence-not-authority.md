# AF-010 — Context Retrieval Is Evidence, Not Authority

Status: Accepted

Confidence: High

## Question

Should Matilda project context retrieval treat retrieved repository artifacts as authoritative system truth?

## Evidence

### Repository Evidence

Inspection identified:

- Project-scoped context retrieval that gathers bounded excerpts from the active registered project.
- Existing architecture separating evidence preservation, interpretation, lifecycle authority, runtime authority, and canonical meaning artifacts.
- Existing findings establishing that historical artifacts, documents, and implementation remnants must not automatically represent current runtime behavior.
- Existing governance patterns where authority belongs to the responsible domain rather than to the artifact that happens to contain information.

### Reasoning

Context retrieval answers which evidence may be relevant to an interpretation request.

It does not establish whether that evidence is authoritative.

A retrieved document, source file, checkpoint, or historical artifact may provide useful context while still being:

- historical,
- proposed,
- deferred,
- non-authoritative,
- superseded,
- or incomplete.

Authority must continue to be determined by the responsible domain, such as:

- active runtime ownership,
- canonical governance artifacts,
- lifecycle authority,
- meaning authority,
- or other established authority boundaries.

## Finding

Matilda project context retrieval is an evidence-providing layer, not an authority-resolution layer.

Retrieved context must remain classified as candidate evidence unless a separate authority determination establishes otherwise.

## Implications

Future Matilda context systems should preserve separation between:

- evidence retrieval,
- artifact classification,
- authority resolution,
- interpretation,
- and approved meaning.

Repository search or retrieval success must not be treated as proof that a retrieved artifact represents current authoritative truth.

## Relationship To Existing Architecture

This finding extends existing principles:

- evidence-first discipline,
- runtime authority boundaries,
- canonical artifact ownership,
- lineage preservation,
- domain-based authority separation.

## Explicit Non-Goals

This finding does not authorize:

- an authority resolution engine,
- automatic artifact trust scoring,
- replacement of existing governance authority models,
- automatic promotion of retrieved evidence into canonical meaning.

## Supersedes

None.
