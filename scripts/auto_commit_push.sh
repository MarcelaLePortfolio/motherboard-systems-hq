
#!/bin/bash

set -e

git add -A

git commit -m "chore: sync system-wide changes across governance, cognition, orchestration, and worker layers"

git push

