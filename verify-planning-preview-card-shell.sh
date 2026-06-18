
#!/usr/bin/env bash

set -euo pipefail

echo "--- planning preview module syntax ---"

node --check public/js/planning-preview-card.js

echo

echo "--- dashboard bundle imports planning preview ---"

grep -n 'planning-preview-card.js' public/js/dashboard-bundle-entry.js

echo

echo "--- served dashboard loads dashboard bundle entry ---"

grep -n 'dashboard-bundle-entry.js' public/dashboard.html

echo

echo "--- planning preview mount targets exist on served dashboard ---"

grep -nE 'id="task-events-card"|id="recent-tasks-card"|id="observational-panels"' public/dashboard.html

echo

echo "--- current git head ---"

git log --oneline -5

