
#!/usr/bin/env bash

set -euo pipefail

TEST_SCRIPT="/tmp/test-launchagent-volume-access.sh"

cat > "$TEST_SCRIPT" << 'INNER_EOF'

#!/bin/bash

set -u

STAMP="$(date +%Y%m%d_%H%M%S)"

DEST="/Volumes/Rio Drive/Motherboard_External_Backup/launchagent_write_test_$STAMP"

echo "USER=$(whoami)"

echo "DEST=$DEST"

mkdir -p "$DEST"

echo "hello from launch context" > "$DEST/test.txt"

ls -la "$DEST"

rm -rf "$DEST"

INNER_EOF

chmod +x "$TEST_SCRIPT"

echo "## Direct shell execution"

/bin/bash "$TEST_SCRIPT"

echo

echo "## launchctl asuser execution"

launchctl asuser "$(id -u)" /bin/bash "$TEST_SCRIPT"

git add test-launchagent-volume-write.sh

git commit -m "Add launchagent volume write test"

git push

