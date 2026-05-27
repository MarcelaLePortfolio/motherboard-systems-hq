/* eslint-disable import/no-commonjs */
#!/bin/bash
cd "$(dirname "$0")/../ui/dashboard/public"
exec npx serve -l 3000
