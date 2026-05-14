
PHASE 719 ARTIFACT FILE LOCATION MISMATCH NOTE

Current result:

- The preview route is mounted and DB access works.

- It returns artifact_file_missing, meaning metadata exists but dashboard container cannot see the artifact file at the recorded path.

Next decision:

- If worker has /app/data/artifacts but dashboard does not, mount the same guidance_data volume into worker OR use the correct shared volume path.

- Do not patch preview rendering until file visibility is resolved.

- Avoid broad static mounts.

