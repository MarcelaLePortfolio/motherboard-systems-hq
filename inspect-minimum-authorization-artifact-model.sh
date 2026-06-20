
#!/usr/bin/env bash

REPORT="minimum-authorization-artifact-model-inspection.txt"

{

  echo "MINIMUM AUTHORIZATION ARTIFACT MODEL INSPECTION"

  echo

  echo "--- doctrine sources ---"

  rg -n -i \

    "proposal_id|review validity|authorization validity|risk disclosure|risk acceptance|residual risk|authorization" \

    . \

    -g '!backups/**' \

    -g '!node_modules/**' || true

  echo

  echo "--- future artifact surfaces ---"

  cat future-authorization-artifact-surfaces-finding.txt 2>/dev/null || true

} | tee "$REPORT"

