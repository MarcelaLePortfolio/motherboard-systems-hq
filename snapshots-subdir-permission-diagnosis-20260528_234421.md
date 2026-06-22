# Snapshots Subdir Permission Diagnosis

Repo: /Users/marcela-dev/Projects/motherboard-systems-hq-clean
Branch: feature/backup-system-v2
HEAD: 01d3e652c9ba281985a23a11521bd760c1a7752d

## Snapshot Root

/Volumes/Rio Drive/Motherboard_External_Backup/snapshots

drwx------  1 marcela-dev  staff  1048576 May 27 13:58 /Volumes/Rio Drive/Motherboard_External_Backup/snapshots

## Direct shell snapshots-subdir write

USER=marcela-dev
DEST=/Volumes/Rio Drive/Motherboard_External_Backup/snapshots/launchagent_snapshots_test_20260528_234421
total 6144
drwx------  1 marcela-dev  staff  1048576 May 28 23:44 .
drwx------  1 marcela-dev  staff  1048576 May 27 13:58 ..
-rwx------  1 marcela-dev  staff       33 May 28 23:44 test.txt

## launchctl asuser snapshots-subdir write

USER=marcela-dev
DEST=/Volumes/Rio Drive/Motherboard_External_Backup/snapshots/launchagent_snapshots_test_20260528_234421
total 6144
drwx------  1 marcela-dev  staff  1048576 May 28 23:44 .
drwx------  1 marcela-dev  staff  1048576 May 27 13:58 ..
-rwx------  1 marcela-dev  staff       33 May 28 23:44 test.txt

## Direct backup script execution

tar: Must specify one of -c, -r, -t, -u, -x
