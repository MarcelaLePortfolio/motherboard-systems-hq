#!/usr/bin/env bash
set +e

cd "$(git rev-parse --show-toplevel)"

branch="$(git branch --show-current)"
git push -u origin "$branch" 2>&1 | tee /tmp/phase61_git_push.log
push_exit=${PIPESTATUS[0]}
echo "git_push_exit=$push_exit"
tail -n 40 /tmp/phase61_git_push.log
exit 0
