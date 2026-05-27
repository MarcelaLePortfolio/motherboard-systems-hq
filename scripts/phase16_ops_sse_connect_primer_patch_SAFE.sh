#!/usr/bin/env bash
set -euo pipefail
cd "$(cd "$(dirname "$0")/.." && pwd)"

FILE="server.mjs"
[[ -f "$FILE" ]] || { echo "ERROR: server.mjs not found"; exit 1; }

# Insert a marker + primer write inside the existing /events/ops handler.
# We do NOT rely on huge regexes; we only look for the handler start and insert immediately after it.
perl -0777 -i -pe '
  sub has { my ($re,$s)=@_; return $s =~ /$re/s; }

  my $mark = "PHASE16_OPS_CONNECT_PRIMER";
  if (!has(qr/\Q$mark\E/, $_)) {
    my $ins = <<'"'"'INS'"'"';
    // PHASE16_OPS_CONNECT_PRIMER
    // Ensure the client receives bytes immediately (prevents empty-body reads)
    try { if (typeof res.flushHeaders === "function") res.flushHeaders(); } catch (_) {}
    try { res.write(": ops-sse-connected\n\n"); } catch (_) {}
INS

    my $n = 0;
    $_ =~ s#(app\.get\(\s*["'"'"']\/events\/ops["'"'"']\s*,\s*\(req\s*,\s*res\)\s*=>\s*\{\s*\n)#$1$ins#s and $n++;
    $_ =~ s#(app\.get\(\s*["'"'"']\/events\/ops["'"'"']\s*,\s*\(req\s*,\s*res\)\s*=>\s*\{)#$1\n$ins#s and $n++ if $n==0;

    if ($n == 0) {
      die "Could not find /events/ops handler signature to patch.\n";
    }
  }

  $_;
' "$FILE"

echo "✅ SAFE patch applied: /events/ops now writes a primer comment immediately on connect"
