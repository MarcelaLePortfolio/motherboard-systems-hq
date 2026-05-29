# Nightly Disaster Backup Executor Disabled

Repo: /Users/marcela-dev/Projects/motherboard-systems-hq-clean
Branch: feature/backup-system-v2
HEAD: f59a24cb996255625e54ef2bbc9a0eb93251768e

## Reason

Manual disaster backup execution now succeeds.
The scheduled LaunchAgent execution path still hits macOS external-volume permission denial.
Because nightly backups are not desired, the clean resolution is to disable the scheduled disaster-backup executor rather than keep a failing automatic job.

## Before

gui/501/com.motherboard.disaster.backup = {
	active count = 0
	path = /Users/marcela-dev/Library/LaunchAgents/com.motherboard.disaster.backup.plist
	type = LaunchAgent
	state = not running

	program = /bin/bash
	arguments = {
		/bin/bash
		/Users/marcela-dev/Projects/motherboard-systems-hq-clean/scripts/disaster-recovery/create-phase736-external-backup.sh
	}

	stdout path = /Users/marcela-dev/Projects/motherboard-systems-hq-clean/logs/disaster-backup.out.log
	stderr path = /Users/marcela-dev/Projects/motherboard-systems-hq-clean/logs/disaster-backup.err.log
	inherited environment = {
		SSH_AUTH_SOCK => /private/tmp/com.apple.launchd.DSoTtRWSS8/Listeners
	}

	default environment = {
		PATH => /usr/bin:/bin:/usr/sbin:/sbin
	}

	environment = {
		XPC_SERVICE_NAME => com.motherboard.disaster.backup
	}

	domain = gui/501 [100003]
	asid = 100003
	minimum runtime = 10
	exit timeout = 5
	runs = 4
	last exit code = 1

	event triggers = {
		com.motherboard.disaster.backup.268435472 => {
			keepalive = 0
			service = com.motherboard.disaster.backup
			stream = com.apple.launchd.calendarinterval
			monitor = com.apple.UserEventAgent-Aqua
			descriptor = {
				"Minute" => 30
				"Hour" => 2
			}
		}
	}

	event channels = {
		"com.apple.launchd.calendarinterval" = {
			port = 0xd8c37
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

	properties = runatload | inferred program
}


## After

Bad request.
Could not find service "com.motherboard.disaster.backup" in domain for user gui: 501

## Fixed Manual Backup Script

-rwxr-xr-x  1 marcela-dev  staff  745 May 28 23:51 scripts/disaster-recovery/create-phase736-external-backup.sh

## Latest Successful Manual Snapshot

drwx------  1 marcela-dev  staff   1.0M May 27 14:16 20260527_141659
drwx------  1 marcela-dev  staff   1.0M May 27 14:17 20260527_141741
drwx------  1 marcela-dev  staff   1.0M May 27 14:18 20260527_141819
drwx------  1 marcela-dev  staff   1.0M May 27 14:18 20260527_141840
drwx------  1 marcela-dev  staff   1.0M May 27 14:19 20260527_141948
drwx------  1 marcela-dev  staff   1.0M May 27 14:25 20260527_142535
drwx------  1 marcela-dev  staff   1.0M May 28 23:44 20260528_234421
drwx------  1 marcela-dev  staff   1.0M May 28 23:48 20260528_234849
drwx------  1 marcela-dev  staff   1.0M May 28 23:50 20260528_235010
drwx------  1 marcela-dev  staff   1.0M May 28 23:51 20260528_235134

## Retention Manager Status

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
	runs = 2
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
