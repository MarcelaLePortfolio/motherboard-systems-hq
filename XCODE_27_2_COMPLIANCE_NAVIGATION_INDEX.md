# Xcode 27.2 — Architecture and Development Compliance Navigation

Status: REFERENCE INDEX / REVIEW GATES ONLY
Created: November 6, 2026

## Purpose

Make the Xcode 27.2 compliance obligations discoverable when relevant
architectural elements or development stages are reviewed.

Canonical compliance register:
[XCODE_27_2_COMPLIANCE_REVIEW.md](XCODE_27_2_COMPLIANCE_REVIEW.md)

This index does not introduce new requirements, authorize implementation,
change architectural invariants, or establish development-stage completion.

## 1. Architectural Element Mapping

| Architectural element | Relevant compliance consideration | Register section |
| --- | --- | --- |
| Cade and Effie | Apple-model output restrictions, model provenance, third-party component licensing | 2, 3, 6 |
| Chief of Staff and market-facing agent generation | Proprietary construct isolation, redistribution restrictions, commercial readiness | 3, 4, 6 |
| Ellis iPhone feasibility | Apple SDK licensing, authorized test devices, provisioning, distribution | 4, 5 |
| Agent self-improvement pipelines | Restrictions on using Apple-model outputs to improve other AI models | 2 |
| Governance and execution authority | Authorization boundaries, human approval, permission controls | 5, 8 |
| Third-party integrations | Component licensing, security, privacy, data handling | 3, 5 |
| Generated code and deliverables | Intellectual property, attribution, testing, open-source obligations | 6 |
| Deployment and release governance | Distribution agreements, operational exposure, release review | 4, 7, 8 |

These mappings identify review relevance, not confirmed use of Apple
models, Apple services, or restricted components.

## 2. Development Stage Mapping

### Stage A — Architecture and Design

Review when:
- Selecting Apple-specific frameworks or services
- Designing AI model integrations
- Defining internal versus market-facing agent boundaries

Relevant register sections: 2, 3, 8.

### Stage B — Local Implementation

Review when:
- Introducing Apple SDK dependencies
- Incorporating Apple-generated content or third-party components
- Modifying code-generation or model-improvement workflows

Relevant register sections: 2, 3, 6.

### Stage C — Device Feasibility and Validation

Review when:
- Preparing Ellis for physical-device testing
- Configuring signing or provisioning
- Introducing device identifiers, permissions, or telemetry

Relevant register sections: 4, 5, 8.

### Stage D — External Testing and Demonstration

Review when:
- Granting access to external testers
- Demonstrating market-facing agents
- Sharing applications, generated artifacts, or licensed components

Relevant register sections: 3, 4, 5, 6.

### Stage E — Commercial Distribution

Review when:
- Preparing applications for public release
- Delivering Chief of Staff or other commercial agents
- Establishing distribution agreements or commercial commitments

Relevant register sections: 3, 4, 6, 7, 8.

### Stage F — Maintenance and Evolution

Review when:
- Upgrading Apple SDKs or developer agreements
- Changing model providers or third-party integrations
- Modifying distribution channels or privacy practices

Relevant register sections: 2, 3, 5, 7, 8.

## 3. Existing Project Documentation Discovery

Potentially relevant repository documentation families include:

- Ellis Stage 3 design and governance records
- Ellis production integration and readiness records
- Agent architecture and generation documentation
- Governance and execution-authority documentation
- Development-stage and release-readiness documentation

These are discovery categories, not verified links to specific
documents. Existing historical records remain authoritative for
their own scope and status.

## 4. Review Procedure

When entering a relevant development stage:

1. Identify the architectural element and proposed activity.
2. Consult the applicable mapping in this index.
3. Read the corresponding sections of the canonical compliance register.
4. Verify current Apple and third-party license terms where applicable.
5. Record any required decision or approval in the existing governance process.
6. Do not proceed beyond the authorized development scope.

## 5. Outstanding Boundaries

- Xcode 27.2 installation and license acceptance are complete.
- Post-installation technical validation remains a separate activity.
- This index does not authorize Ellis device deployment.
- This index does not authorize Apple Foundation Models integration.
- This index does not authorize commercial distribution.
- No existing architectural document or historical stage record is modified.
- Repository commit and push require separate authorization.

## 6. Maintenance

Update this index when a verified architectural relationship or
development-stage review trigger changes.

Preserve the canonical compliance register as the primary reference.
Avoid duplicating its substantive requirements in individual
architectural documents.

Changes to this index must follow existing repository governance,
scope authorization, and version-control procedures.
