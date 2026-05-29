# Retention Scope Boundary Verification

## Manager Base Path

12:BASE="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

## References To backups/


## References To Motherboard_External_Backup


## References To Motherboard_Storage

/Users/marcela-dev/motherboard-backup-system/snapshot-manager-prod.sh:12:BASE="/Volumes/Rio Drive/Motherboard_Storage/snapshots"

## Enumerated Directories

Local backups:
 25G	backups

Motherboard_Storage:
 68G	/Volumes/Rio Drive/Motherboard_Storage/snapshots

Motherboard_External_Backup:
6.9G	/Volumes/Rio Drive/Motherboard_External_Backup/snapshots

## Conclusion

Review the paths above. The retention manager can only govern locations it explicitly references.
