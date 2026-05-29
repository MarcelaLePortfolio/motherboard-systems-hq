# Disaster Backup + Retention Health Verification

Repo: /Users/marcela-dev/Projects/motherboard-systems-hq-clean
External backup root: /Volumes/Rio Drive/Motherboard_External_Backup
Timestamp: Thu May 28 23:29:57 PDT 2026

## LaunchAgents

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
	runs = 2
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

--------------------------------

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

## Backup Logs

### stdout

### stderr
mkdir: /Volumes/Rio Drive/Motherboard_External_Backup/snapshots/20260528_232706: Operation not permitted

## Retention Logs

/Users/marcela-dev/Projects/motherboard-systems-hq-clean/memory/prune.log
/Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups/_restore_test/memory/prune.log
/Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups/dr_daemon.log
/Volumes/Rio Drive/Motherboard_External_Backup/snapshots/20260527_141840/project/memory/prune.log
/Volumes/Rio Drive/Motherboard_External_Backup/logs/prune.log

## Recent External Snapshots

total 20480
drwx------  1 marcela-dev  staff   1.0M Dec 18 16:17 20260527_141942_snapshot
drwx------  1 marcela-dev  staff   1.0M Dec 18 16:17 20260527_140933_snapshot
drwx------  1 marcela-dev  staff   1.0M Dec 18 16:17 20260527_135824_snapshot
drwx------  1 marcela-dev  staff   1.0M May 27 14:14 20260527_141415
drwx------  1 marcela-dev  staff   1.0M May 27 14:16 20260527_141659
drwx------  1 marcela-dev  staff   1.0M May 27 14:17 20260527_141741
drwx------  1 marcela-dev  staff   1.0M May 27 14:18 20260527_141819
drwx------  1 marcela-dev  staff   1.0M May 27 14:18 20260527_141840
drwx------  1 marcela-dev  staff   1.0M May 27 14:19 20260527_141948
drwx------  1 marcela-dev  staff   1.0M May 27 14:25 20260527_142535

## Latest Snapshot Contents

Latest snapshot: /Volumes/Rio Drive/Motherboard_External_Backup/snapshots/20260527_142535

2.0M	/Volumes/Rio Drive/Motherboard_External_Backup/snapshots/20260527_142535

## Disk Usage

Filesystem      Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s5   228Gi   143Gi    47Gi    76%    816k  497M    0%   /System/Volumes/Data

Filesystem      Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk4s1   931Gi   296Gi   635Gi    32%       1     0  100%   /Volumes/Rio Drive

 25G	backups
5.7G	/Volumes/Rio Drive/Motherboard_External_Backup
