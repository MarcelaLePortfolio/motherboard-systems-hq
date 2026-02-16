#!/usr/bin/env bash
set -euo pipefail

TAG="${1:-}"
if [[ -z "$TAG" ]]; then
  echo "usage: $0 <tag>" >&2
  exit 2
fi

head_sha="$(git rev-parse HEAD)"
tag_obj="$(git rev-parse "$TAG")"
tag_commit="$(git rev-parse "${TAG}^{}")"

echo "HEAD:       $head_sha"
echo "TAG object: $tag_obj"
echo "TAG -> git: $tag_commit"

if [[ "$head_sha" == "$tag_commit" ]]; then
  echo "OK: ${TAG}^{} == HEAD"
  exit 0
fi

echo "ERROR: ${TAG}^{} != HEAD" >&2
exit 1
