#!/usr/bin/env bash
set -e

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

# Ensure delegation-wire.js is actually loaded on the dashboard page

# by injecting a script tag before the closing </body>.

# Previous attempt targeted "  </body>" (indented), which did not match.

# This one matches plain </body>.

perl -0pi -e 's@</body>@  <script src="/js/delegation-wire.js"></script>\n</body>@' public/dashboard.html
