# Recovery Checkpoints

## Phase 60 Agent Pool Polish Preview

- Git tag: v60.0-agent-pool-polish-preview
- Image tag: motherboard_systems_hq-dashboard:v60.0-agent-pool-polish-preview
- Local image archive: .artifacts/docker/motherboard_systems_hq-dashboard_v60.0-agent-pool-polish-preview.tar

Notes:
- This preserves the approved Phase 60 Agent Pool visual polish state.
- Git tag is the source-of-truth code checkpoint.
- Docker image tag is the source-of-truth build checkpoint.
- Local tar archive is for fast recovery outside git.
- Runtime is not yet a golden boot artifact until launched successfully with required environment variables, including POSTGRES_URL.
