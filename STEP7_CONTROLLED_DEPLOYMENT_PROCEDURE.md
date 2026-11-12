# Step 7 — Controlled Runtime Security Reconciliation

Status: PREPARED — NOT AUTHORIZED FOR EXECUTION

## Objective

Replace only the compiled server entry point so that the application listens on
127.0.0.1:3000 rather than all interfaces.

Dashboard deployment, frontend integration, and unrelated source changes are excluded.

## Verified baseline

Repository HEAD:
6efe7021196f54259dded1fb77482171b5839dd6

Current compiled entry point:
dist/server/index.js

Current SHA-256:
8cc7557ef78a6ca81ac6b1f2718e6d581d3263c74cf209509f5eb6ab32dcbb32

Replacement candidate:
/var/folders/3n/zscyzgr50b9gk8dg6fv8byz80000gn/T/motherboard-runtime-step7.ene70Spa/server/index.js

Candidate SHA-256:
ed5c5c337fb360bbc852989f4389d5fc9a809c13fbc12ea4f35b9bb6dd94b1b7

Recovery archive:
/Volumes/Rio Drive/backups/source_NONDESTRUCTIVE_20261111_192543_abb5cdca5e02.tar.gz

Recovery archive SHA-256:
3efac6cc4ea118217fb50b99160c1b32289a83c707c7cb262b7097c039eb6e7a

The archive contains an exact copy of the current compiled entry point.

## Protected state

The following uncommitted modifications must remain untouched:

- server/index.ts
- client/vite.config.ts

Do not reset, overwrite, or stage unrelated modifications.

## Execution prerequisites

1. Reverify the protected Git HEAD.
2. Reverify both compiled artifact checksums.
3. Reverify the recovery archive checksum.
4. Confirm the original process still owns port 3000.
5. Confirm its executable, working directory, and runtime environment.
6. Establish a persistent rollback copy outside the live compiled directory.
7. Establish a reliable process launch and supervision mechanism.
8. Establish a tested procedure for restoring the original artifact.
9. Verify that the Cloudflare tunnel targets localhost:3000.
10. Obtain separate authorization before production execution.

Any failed prerequisite stops execution.

## Proposed controlled deployment

After all prerequisites pass and execution is separately authorized:

1. Preserve the original compiled entry point.
2. Verify the preserved copy against the original SHA-256.
3. Stage the replacement candidate without changing source files.
4. Confirm the expected process identity immediately before termination.
5. Stop only the verified application process.
6. Atomically replace the compiled entry point.
7. Start the server using the approved launch procedure.
8. Verify the new process listens exclusively on 127.0.0.1:3000.
9. Verify unauthenticated requests to /ui and /api/projects/registry return HTTP 401.
10. Verify expected Cloudflare tunnel connectivity and authenticated access.
11. Reverify protected repository state.

Do not declare success based solely on compilation or process startup.

## Failure containment

If deployment or validation fails:

1. Stop the replacement process if running.
2. Restore the original compiled entry point from the verified rollback copy.
3. Verify the restored artifact checksum.
4. Restart using the approved launch procedure.
5. Verify service availability and access-control behavior.
6. Record the failure and stop further deployment attempts.

If the original service cannot be restored, stop and report the exact failure.
Do not attempt speculative additional repairs.

No more than three failed attempts are permitted for one hypothesis.
Reassess the approach after rollback rather than layering fixes.

## Current unresolved items

- Original process appears to have originated from terminal ttys135.
- No automatic restart manager has been verified.
- The exact runtime environment has not been captured.
- The compiled entry point is not tracked by Git.
- Complete service rollback has not been tested.
- Production continues to listen on all interfaces.

## Authorization boundary

This document is preparation only.

It does not authorize:
- Replacing production artifacts
- Terminating or restarting processes
- Changing source files
- Deploying the dashboard
- Modifying Cloudflare configuration

Next gate: Review the deployment procedure and explicitly authorize
the remaining prerequisite verification before production execution.
