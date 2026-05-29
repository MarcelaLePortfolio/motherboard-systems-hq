# Disaster Backup LaunchAgent Repair

Repo: /Users/marcela-dev/Projects/motherboard-systems-hq-clean
Plist: /Users/marcela-dev/Library/LaunchAgents/com.motherboard.disaster.backup.plist
Old script: /Users/marcela-dev/Projects/Motherboard_Systems_HQ/scripts/disaster-recovery/create-phase736-external-backup.sh
New script: /Users/marcela-dev/Projects/motherboard-systems-hq-clean/scripts/disaster-recovery/create-phase736-external-backup.sh

## Before
gui/501/com.motherboard.disaster.backup = {
	active count = 0
	path = /Users/marcela-dev/Library/LaunchAgents/com.motherboard.disaster.backup.plist
	type = LaunchAgent
	state = not running

	program = /bin/bash
	arguments = {
		/bin/bash
		/Users/marcela-dev/Projects/Motherboard_Systems_HQ/scripts/disaster-recovery/create-phase736-external-backup.sh
	}

	stdout path = /Users/marcela-dev/Projects/Motherboard_Systems_HQ/logs/disaster-backup.out.log
	stderr path = /Users/marcela-dev/Projects/Motherboard_Systems_HQ/logs/disaster-backup.err.log
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
	last exit code = 127

	event triggers = {
		com.motherboard.disaster.backup.268435471 => {
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
			port = 0x92503
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

## Script Existence
Old exists: NO
New exists: NO


## After
gui/501/com.motherboard.disaster.backup = {
	active count = 1
	path = /Users/marcela-dev/Library/LaunchAgents/com.motherboard.disaster.backup.plist
	type = LaunchAgent
	state = running

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
	pid = 4669
	immediate reason = non-ipc demand
	forks = 0
	execs = 1
	initialized = 1
	trampolined = 1
	started suspended = 0
	proxy started suspended = 0
	last terminating signal = Terminated: 15

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
			watching = 0
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
