
#!/usr/bin/env bash

REPORT="doctrine-architecture-consistency-inspection.txt"

{

  echo "DOCTRINE TO ARCHITECTURE CONSISTENCY INSPECTION"

  echo

  echo "--- doctrine evidence ---"

  rg -n -i \

    "intended future state|unnecessary risk|residual risk|human acceptance|authorization validity|review validity|risk visibility" \

    . \

    -g '!backups/**' \

    -g '!node_modules/**'

  echo

  echo "--- execution implementation ---"

  rg -n -i \

    "execution_authorization|mutation_authorization|shell_authorization|autonomous_authorization|planning-only|runtime execution authorization" \

    server/execution server/contracts

} | tee "$REPORT"

