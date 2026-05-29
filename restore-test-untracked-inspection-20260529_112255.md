# Restore Test Untracked Inspection

## Restore Test Status
?? .backup_excludes
?? backups/
?? scripts/vault_layer.sh

## Untracked Top-Level Sizes
4.0K	backups/_restore_test/.backup_excludes
8.2G	backups/_restore_test/backups
4.0K	backups/_restore_test/scripts/vault_layer.sh

## Does current repo already have these?
-rw-r--r--  1 marcela-dev  staff  38 May 27 15:29 .backup_excludes
drwxr-xr-x  10 marcela-dev  staff  320 May 29 09:47 backups
-rwxr-xr-x  1 marcela-dev  staff  1001 May 27 15:28 scripts/vault_layer.sh

## Conclusion Aid
If only backups/_restore_test/backups is large, it is likely nested backup duplication inside a restored repo.
