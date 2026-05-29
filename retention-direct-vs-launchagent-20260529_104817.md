# Retention Direct vs LaunchAgent Comparison

## One-line Inventory
external_dirs=5
 rio_backups_dirs=1
 local_dirs=4


## Direct Shell Metrics

{

  "timestamp": "Fri May 29 10:48:20 PDT 2026",

  "status": "OK",

  "scanned": 19,

  "deleted": 9,

  "bytes_deleted": 6050283520,

  "missing_roots": 0,

  "safety_blocked": 0,

  "duration_seconds": 3

}

## Direct Shell Reconciliation

{

  "timestamp": "Fri May 29 10:48:20 PDT 2026",

  "verdict": "OK",

  "mode": "safe_autonomous_directory_unit_retention",

  "archive_old_backups": false,

  "compress_old_backups": false,

  "delete_known_backup_units_only": true,

  "keep_newest_per_root": 5,

  "minimum_age_seconds_before_delete": 86400,

  "roots_ok": 3,

  "missing_roots": 0,

  "scanned": 19,

  "deleted": 9,

  "bytes_deleted": 6050283520,

  "safety_blocked": 0,

  "duration_seconds": 3,

  "confidence": 1.0

}

## LaunchAgent Metrics

{

  "timestamp": "Fri May 29 10:48:20 PDT 2026",

  "status": "OK",

  "scanned": 4,

  "deleted": 0,

  "bytes_deleted": 0,

  "missing_roots": 0,

  "safety_blocked": 0,

  "duration_seconds": 0

}

## LaunchAgent Reconciliation

{

  "timestamp": "Fri May 29 10:48:20 PDT 2026",

  "verdict": "OK",

  "mode": "safe_autonomous_directory_unit_retention",

  "archive_old_backups": false,

  "compress_old_backups": false,

  "delete_known_backup_units_only": true,

  "keep_newest_per_root": 5,

  "minimum_age_seconds_before_delete": 86400,

  "roots_ok": 3,

  "missing_roots": 0,

  "scanned": 4,

  "deleted": 0,

  "bytes_deleted": 0,

  "safety_blocked": 0,

  "duration_seconds": 0,

  "confidence": 1.0

}

## LaunchAgent stderr

## Current Unit File Counts
.retention-units-0778717b23c034f3af383ed2e45e52e6628011063162a808eae3d5450c287777.txt count=0
.retention-units-17c613fdcafe3d0794e6d48e925149b35b9b295eb857cab2ab5e1f6bd43eb481.txt count=0
.retention-units-955f8e0aee5c7528eadd87526b7b2137e8dea23e83479f085b803ea9e2934b74.txt count=4
