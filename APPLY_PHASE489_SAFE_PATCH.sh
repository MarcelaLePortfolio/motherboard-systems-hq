#!/usr/bin/env bash

set -e

echo "STEP 1: create backup"
cp server.mjs server.mjs.bak

echo "STEP 2: apply surgical patch (ONLY target block)"
awk '
BEGIN { replaced=0 }

{
  if ($0 ~ /return res\.json\(\{/ && replaced==0) {
    print "      // PHASE489: minimal read-only run_view awareness (safe, no mutations)"
    print "      let runSummary = \"No recent runs.\";"
    print "      try {"
    print "        const q = `SELECT run_id, task_status FROM run_view ORDER BY last_event_ts DESC LIMIT 1`;"
    print "        const r = await pool.query(q);"
    print "        if (r.rows && r.rows.length > 0) {"
    print "          const row = r.rows[0];"
    print "          runSummary = `Latest run: ${row.run_id} (${row.task_status})`;"
    print "        }"
    print "      } catch (e) {"
    print "        console.warn(\"[PHASE489] run_view probe failed\", e?.message || e);"
    print "      }"
    print ""
    print "      return res.json({"
    print "        ok: true,"
    print "        agent: requestedAgent,"
    print "        mode: \"deterministic-local-response\","
    print "        message,"
    print "        reasoning: ["
    print "          `Agent selected: ${requestedAgent}`,"
    print "          `Message length: ${message.length}`,"
    print "          \"Mode: deterministic local response layer\","
    print "          \"External runtime: disabled\","
    print "          \"Execution class: UI-safe acknowledgement\","
    print "        ].join(\" | \"),"
    print "        reply: ["
    print "          `${requestedAgent.charAt(0).toUpperCase() + requestedAgent.slice(1)} received your request.`,"
    print "          `Input: \\\"${message}\\\"`,"
    print "          runSummary,"
    print "          \"Status: deterministic local response active.\","
    print "          \"Runtime handoff: not enabled in this corridor.\","
    print "          \"Next step: provide a specific task or request an auditable system action.\","
    print "        ].join(\"\\n\"),"
    print "        meta: {"
    print "          timestamp: \"deterministic-local\","
    print "          pipeline: \"matilda-stub\","
    print "        },"
    print "      });"

    replaced=1
    skip=1
    next
  }

  if (skip==1) {
    if ($0 ~ /\}\);/) {
      skip=0
    }
    next
  }

  print
}
END {
  if (replaced==0) {
    print "ERROR: target block not found" > "/dev/stderr"
    exit 1
  }
}
' server.mjs > server.mjs.tmp

mv server.mjs.tmp server.mjs

echo "STEP 3: syntax check"
node --check server.mjs

echo "STEP 4: commit"
git add server.mjs
git commit -m "PHASE489: safe minimal run_view awareness added to /api/chat"

echo "STEP 5: push"
git push

echo "DONE"
