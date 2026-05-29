# Nested Restore-Test Backups Removal

## Before
8.2G	backups/_restore_test/backups
8.7G	backups/_restore_test
8.7G	backups

## Removing
backups/_restore_test/backups

## After
backups/_restore_test/backups removed
457M	backups/_restore_test
457M	backups

## Restore Test Remaining Git Status
?? .backup_excludes
?? scripts/vault_layer.sh
