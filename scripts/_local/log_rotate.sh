/* eslint-disable import/no-commonjs */
cd ~/Desktop/Motherboard_Systems_HQ/memory || exit 1
timestamp=$(date +"%Y%m%d_%H%M%S")
tar czf cade_logs_$timestamp.tar.gz cade_*.log 2>/dev/null
: > cade_runtime.log
