# Retention Manager Process Verification

Repo: /Users/marcela-dev/Projects/motherboard-systems-hq-clean
Branch: feature/backup-system-v2
HEAD: 2c5ce348516db630d64ca638ed67cf57fac4b4bd

## LaunchAgent Status

gui/501/com.motherboard.snapshot.retention = {
	active count = 0
	path = /Users/marcela-dev/Library/LaunchAgents/com.motherboard.snapshot.retention.plist
	type = LaunchAgent
	state = not running

	program = /bin/bash
	arguments = {
		/bin/bash
		/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh
	}

	working directory = /Users/marcela-dev/motherboard-backup-system

	stdout path = /Users/marcela-dev/motherboard-backup-system/launchd.out.log
	stderr path = /Users/marcela-dev/motherboard-backup-system/launchd.err.log
	inherited environment = {
		SSH_AUTH_SOCK => /private/tmp/com.apple.launchd.DSoTtRWSS8/Listeners
	}

	default environment = {
		PATH => /usr/bin:/bin:/usr/sbin:/sbin
	}

	environment = {
		XPC_SERVICE_NAME => com.motherboard.snapshot.retention
	}

	domain = gui/501 [100003]
	asid = 100003
	minimum runtime = 10
	exit timeout = 5
	runs = 3
	last exit code = 0

	event triggers = {
		com.motherboard.snapshot.retention.268435470 => {
			keepalive = 0
			service = com.motherboard.snapshot.retention
			stream = com.apple.launchd.calendarinterval
			monitor = com.apple.UserEventAgent-Aqua
			descriptor = {
				"Minute" => 0
				"Hour" => 2
			}
		}
	}

	event channels = {
		"com.apple.launchd.calendarinterval" = {
			port = 0x92a03
			active = 0
			managed = 1
			reset = 0
			hide = 0
			watching = 1
		}
	}

	spawn type = daemon (3)
	jetsam priority = 40
	jetsam memory limit (active) = (unlimited)
	jetsam memory limit (inactive) = (unlimited)
	jetsamproperties category = daemon
	jetsam thread limit = 32
	cpumon = default
	probabilistic guard malloc policy = {
		activation rate = 1/1000
		sample rate = 1/0
	}

	properties = runatload | inferred program | managed LWCR | has LWCR
}

## Plist


<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">

<plist version="1.0">

<dict>

  <key>Label</key>

  <string>com.motherboard.snapshot.retention</string>

  <key>ProgramArguments</key>

  <array>

    <string>/bin/bash</string>

    <string>/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh</string>

  </array>

  <key>WorkingDirectory</key>

  <string>/Users/marcela-dev/motherboard-backup-system</string>

  <key>RunAtLoad</key>

  <true/>

  <key>StartCalendarInterval</key>

  <dict>

    <key>Hour</key>

    <integer>2</integer>

    <key>Minute</key>

    <integer>0</integer>

  </dict>

  <key>StandardOutPath</key>

  <string>/Users/marcela-dev/motherboard-backup-system/launchd.out.log</string>

  <key>StandardErrorPath</key>

  <string>/Users/marcela-dev/motherboard-backup-system/launchd.err.log</string>

</dict>

</plist>


## Manager Path

total 72
drwxr-xr-x   2 marcela-dev  staff    64 May 25 15:23 _auto_archives
drwxr-xr-x  12 marcela-dev  staff   384 May 25 15:31 .
drwxr-x---+ 95 marcela-dev  staff  3040 May 28 23:46 ..
-rw-r--r--   1 marcela-dev  staff    29 May 29 09:19 last-heartbeat.txt
-rw-r--r--   1 marcela-dev  staff   183 May 29 09:19 last-run-metrics.json
-rw-r--r--   1 marcela-dev  staff     3 May 29 09:19 last-run-status.txt
-rw-r--r--   1 marcela-dev  staff  5805 May 25 15:22 launchd.err.log
-rw-r--r--   1 marcela-dev  staff     0 May 25 15:14 launchd.out.log
-rw-r--r--   1 marcela-dev  staff   227 May 29 09:19 reconciliation.json
-rwx------   1 marcela-dev  staff  1109 May 25 15:14 snapshot-manager-lite.sh
-rwxr-xr-x   1 marcela-dev  staff  3099 May 25 15:31 snapshot-manager-prod.sh
-rw-r--r--   1 marcela-dev  staff   527 May 29 09:19 snapshot-retention.log

## Manager Script

-rwxr-xr-x  1 marcela-dev  staff  3099 May 25 15:31 /Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh

## Manager Syntax


## Manager Script Preview


#!/bin/bash

set +e

# =========================

# CORE PATHS

# =========================

BASE="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

ARCHIVE_DIR="/Users/marcela-dev/motherboard-backup-system/_auto_archives"

SYSTEM_DIR="/Users/marcela-dev/motherboard-backup-system"

LOG_FILE="$SYSTEM_DIR/snapshot-retention.log"

STATE_FILE="$SYSTEM_DIR/last-run-status.txt"

HEARTBEAT_FILE="$SYSTEM_DIR/last-heartbeat.txt"

METRICS_FILE="$SYSTEM_DIR/last-run-metrics.json"

RECON_FILE="$SYSTEM_DIR/reconciliation.json"

mkdir -p "$ARCHIVE_DIR"

START_TIME=$(date +%s)

echo "=== RUN $(date) ===" >> "$LOG_FILE"

# =========================

# SAFETY: MOUNT CHECK

# =========================

if [ ! -d "$BASE" ]; then

  echo "MOUNT_MISSING" > "$STATE_FILE"

  cat > "$RECON_FILE" << JSON

{

  "verdict": "FAILED",

  "reason": "mount_missing",

  "timestamp": "$(date)"

}

JSON

  exit 0

fi

cd "$BASE"

shopt -s nullglob

# =========================

# ACCUMULATORS

# =========================

TOTAL_SCANNED=0

TOTAL_DELETED=0

TOTAL_ARCHIVED=0

SAFETY_BLOCKED=0

EXPECTED_DELETES=0

# =========================

# EXECUTION LOOP

# =========================

for day in $(ls full-disaster-recovery-* 2>/dev/null | cut -d'-' -f4 | sort | uniq); do

  files=(full-disaster-recovery-${day}-*)

  count=${#files[@]}

  TOTAL_SCANNED=$((TOTAL_SCANNED + count))

  if [ "$count" -le 3 ]; then

    continue

  fi

  keep=3

  old_count=$((count - keep))

  old_files=("${files[@]:0:$old_count}")

  EXPECTED_DELETES=$((EXPECTED_DELETES + old_count))

  archive_name="$ARCHIVE_DIR/${day}-archive-$(date +%H%M%S).tar.gz"

  tar -czf "$archive_name" "${old_files[@]}"

  if [ -s "$archive_name" ]; then

    TOTAL_ARCHIVED=$((TOTAL_ARCHIVED + 1))

    for f in "${old_files[@]}"; do

      rm -rf "$f"

      TOTAL_DELETED=$((TOTAL_DELETED + 1))

    done

  else

    SAFETY_BLOCKED=$((SAFETY_BLOCKED + 1))

  fi

done

END_TIME=$(date +%s)

DURATION=$((END_TIME - START_TIME))

# =========================

# RECONCILIATION ENGINE v1

# =========================

DELETION_DIFF=$((TOTAL_DELETED - EXPECTED_DELETES))

if [ "$DELETION_DIFF" -eq 0 ]; then

  VERDICT="OK"

elif [ "$DELETION_DIFF" -lt 0 ]; then

  VERDICT="DEGRADED_UNDERDELETE"

else

  VERDICT="DEGRADED_OVERDELETE"

fi

CONFIDENCE=1.0

cat > "$RECON_FILE" << JSON

{

  "timestamp": "$(date)",

  "verdict": "$VERDICT",

  "expected_deletes": $EXPECTED_DELETES,

  "actual_deletes": $TOTAL_DELETED,

  "diff": $DELETION_DIFF,

  "archives_created": $TOTAL_ARCHIVED,

  "scanned": $TOTAL_SCANNED,

  "safety_blocked": $SAFETY_BLOCKED,

  "confidence": $CONFIDENCE

}

JSON

# =========================

# OBSERVABILITY OUTPUT

# =========================

echo "$(date)" > "$HEARTBEAT_FILE"

echo "OK" > "$STATE_FILE"

cat > "$METRICS_FILE" << METRICS

{

  "timestamp": "$(date)",

  "status": "ok",

  "scanned": $TOTAL_SCANNED,

  "deleted": $TOTAL_DELETED,

  "archives_created": $TOTAL_ARCHIVED,

  "safety_blocked": $SAFETY_BLOCKED,

  "duration_seconds": $DURATION

}

METRICS

echo "=== DONE ===" >> "$LOG_FILE"

## Manager Logs

stdout:

stderr:
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-lite.sh: line 14: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-manager.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-lite.sh: line 68: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-manager.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-lite.sh: line 14: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-manager.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-lite.sh: line 68: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-manager.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 14: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 90: /Volumes/Rio Drive/Motherboard_Storage/snapshots/last-run-status.txt: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 92: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 14: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 90: /Volumes/Rio Drive/Motherboard_Storage/snapshots/last-run-status.txt: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 92: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 14: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 90: /Volumes/Rio Drive/Motherboard_Storage/snapshots/last-run-status.txt: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 92: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 14: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 90: /Volumes/Rio Drive/Motherboard_Storage/snapshots/last-run-status.txt: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 92: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 14: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 90: /Volumes/Rio Drive/Motherboard_Storage/snapshots/last-run-status.txt: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 92: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 14: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 90: /Volumes/Rio Drive/Motherboard_Storage/snapshots/last-run-status.txt: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 92: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 14: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 90: /Volumes/Rio Drive/Motherboard_Storage/snapshots/last-run-status.txt: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 92: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 14: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 72: /Volumes/Rio Drive/Motherboard_Storage/snapshots/last-run-status.txt: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 74: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 20: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 108: /Volumes/Rio Drive/Motherboard_Storage/snapshots/last-heartbeat.txt: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 110: /Volumes/Rio Drive/Motherboard_Storage/snapshots/last-run-status.txt: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 118: /Volumes/Rio Drive/Motherboard_Storage/snapshots/last-run-metrics.json: Operation not permitted
/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh: line 138: /Volumes/Rio Drive/Motherboard_Storage/snapshots/snapshot-retention.log: Operation not permitted

## Disk Safety Snapshot

Filesystem      Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s5   228Gi   144Gi    45Gi    77%    826k  468M    0%   /System/Volumes/Data

Filesystem      Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk4s1   931Gi   298Gi   634Gi    32%       1     0  100%   /Volumes/Rio Drive

 25G	backups
6.9G	/Volumes/Rio Drive/Motherboard_External_Backup
