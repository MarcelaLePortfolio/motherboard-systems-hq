# Retention Manager Fresh Run Verification

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
	runs = 4
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

## Fresh stderr


## Fresh stdout


## Heartbeat

Fri May 29 09:22:44 PDT 2026

## Status

OK

## Metrics


{

  "timestamp": "Fri May 29 09:22:44 PDT 2026",

  "status": "ok",

  "scanned": 0,

  "deleted": 0,

  "archives_created": 0,

  "safety_blocked": 0,

  "duration_seconds": 0

}


## Reconciliation


{

  "timestamp": "Fri May 29 09:22:44 PDT 2026",

  "verdict": "OK",

  "expected_deletes": 0,

  "actual_deletes": 0,

  "diff": 0,

  "archives_created": 0,

  "scanned": 0,

  "safety_blocked": 0,

  "confidence": 1.0

}

