# Retention Unit Lists Inspection

## One-line Counts
external_units=14
 local_units=4
 rio_backups_units=1
 scanned=4


## Generated Retention Unit Files
-rw-------  1 marcela-dev  staff     0B May 29 10:39 /Users/marcela-dev/motherboard-backup-system/.retention-units-0778717b23c034f3af383ed2e45e52e6628011063162a808eae3d5450c287777.txt
-rw-------  1 marcela-dev  staff     0B May 29 10:39 /Users/marcela-dev/motherboard-backup-system/.retention-units-17c613fdcafe3d0794e6d48e925149b35b9b295eb857cab2ab5e1f6bd43eb481.txt
-rw-------  1 marcela-dev  staff   488B May 29 10:39 /Users/marcela-dev/motherboard-backup-system/.retention-units-955f8e0aee5c7528eadd87526b7b2137e8dea23e83479f085b803ea9e2934b74.txt

## Unit File Counts
.retention-units-0778717b23c034f3af383ed2e45e52e6628011063162a808eae3d5450c287777.txt count=0

.retention-units-17c613fdcafe3d0794e6d48e925149b35b9b295eb857cab2ab5e1f6bd43eb481.txt count=0

.retention-units-955f8e0aee5c7528eadd87526b7b2137e8dea23e83479f085b803ea9e2934b74.txt count=4
1779921221 9308786688 DIR /Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups/_restore_test
1779957721 135168 DIR /Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups/dashboard-ui-before-phase91-restore
1779958144 135168 DIR /Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups/dashboard-ui-before-phase715-candidate
1779986448 8192 DIR /Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups/phase530-bridge-before-phase740-surgical-restore

## Manager Root Configuration
90:for BASE in "/Volumes/Rio Drive/backups" "/Volumes/Rio Drive/Motherboard_External_Backup/snapshots" "/Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups"; do
108:    "/Users/marcela-dev/Projects/motherboard-systems-hq-clean/backups")
122:  UNIT_LIST="$SYSTEM_DIR/.retention-units-$(echo "$BASE" | shasum -a 256 | awk '{print $1}').txt"
124:  : > "$UNIT_LIST"
126:  find "$BASE" -mindepth 1 -maxdepth 1 -print 2>/dev/null | while IFS= read -r p; do
134:      echo "$mt $sz FILE $p" >> "$UNIT_LIST"
142:      echo "$mt $sz DIR $p" >> "$UNIT_LIST"
148:  sort -n "$UNIT_LIST" -o "$UNIT_LIST"
150:  COUNT=$(wc -l < "$UNIT_LIST" | tr -d ' ')
244:  done < "$UNIT_LIST"
