# Project Visual Output Screen – Container Deployment Notes

## Status

- Dashboard two-column layout is stable.
- Right-hand Project Visual Output card styled as 3D display.
- Viewport min-height: 640px.
- Chat console + delegation remain functional.
- This commit is the visual baseline for container deployments.

## Recommended Deployment Flow

1. Verify working tree is clean:
      git status

2. Push any pending local commits:
      git push

3. For containerized dashboard via Docker Compose:
      docker compose down
      docker compose build --no-cache
      docker compose up -d

4. For PM2-managed Node process (non-Docker):
      pm2 restart all

5. For local direct Node (no PM2, no Docker):
      npm run build
      node server.mjs

## Notes

- Treat this as the reference point for Phase 11 dashboard demo runs.
- Future visual tweaks should branch from this baseline.
