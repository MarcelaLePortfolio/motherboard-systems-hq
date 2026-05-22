
# Render-Native Payload Contract

Status: LOCKED

Corridor: SANDBOX ONLY

Authoritative payload schema:

phase736.render-native-payload.v1

Verified payload structure:

- schema_version

- artifact_type

- scene

- layout

- layout_tokens

- style_tokens

- nodes

- text

- validation

Verified scene structure:

- id

- root

Verified layout structure:

- mode

Verified node structure:

- id

- type

- style_token

- layout_token

- content

Verified node types:

- container

- text

Verified token propagation:

Layout tokens:

- stack

- card

Style tokens:

- background

- text

- accent

- spacing

Verified validation flags:

- deterministic: true

- sandbox_only: true

Verified deterministic render chain:

semantic intent

→ compiled payload

→ rendered HTML

→ payload inspection report

→ sandbox chain report

Invariant rules:

- no live Preview mutation

- no renderer interception

- no speculative runtime integration

- sandbox remains authoritative experimentation corridor

- payload schema changes require explicit inspection evidence

- renderer integration planning must begin from verified payload contract only

Current authoritative sandbox checkpoint:

- commit: 2bed56e8

- branch: phase730-semantic-section-extraction

