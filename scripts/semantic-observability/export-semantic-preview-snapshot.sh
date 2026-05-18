
#!/bin/bash

set -euo pipefail

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

EXPORT_DIR="runtime/semantic-preview-planning/exports/$TIMESTAMP"

mkdir -p "$EXPORT_DIR"

cat > "$EXPORT_DIR/semantic-preview-snapshot.json" << 'JSON'

{

  "status": "planning-only",

  "rendererAuthority": "preserved",

  "executionAuthority": "preserved",

  "semanticSubstrate": {

    "mode": "observational-only",

    "artifactScoped": true,

    "rendererIndependent": true

  }

}

JSON

echo "Semantic preview snapshot exported:"

echo "$EXPORT_DIR/semantic-preview-snapshot.json"

