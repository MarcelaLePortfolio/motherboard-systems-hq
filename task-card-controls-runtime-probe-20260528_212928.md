# Task Card Controls Runtime Probe

Repo: /Users/marcela-dev/Projects/motherboard-systems-hq-clean
Branch: feature/backup-system-v2
HEAD: ecc25ca8abdb87105bc124119a0455b0d09db8bc

## Runtime Start

 Container motherboard-systems-hq-clean-postgres-1  Running
 Container motherboard-systems-hq-clean-dashboard-1  Running

## Runtime Probe

Task count: 0
Rows with artifact payloads: 0
Rows with trace payloads: 0
Rows with log payloads: 0

## Control Visibility Diagnosis

- Preview pill requires artifact/artifacts payload data.
- Inspect trace requires trace/status_trace/statusTrace payload data.
- Inspect logs requires log/logs/execution_logs payload data.

## API Shape Sample

{
  "api_probe": "unavailable",
  "reason": "localhost:3000/api/tasks did not respond after runtime start attempt"
}
