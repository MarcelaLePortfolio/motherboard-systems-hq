
#!/usr/bin/env bash

echo "Locking Express + Express types..."

# remove any accidental duplicate installs

npm uninstall @types/express

# reinstall clean v4 alignment

npm i -D @types/express@4

echo "Done"

