$(awk '
NR==374 {print}
NR>=394 && NR<=417 {
  if (!patched) {
    print "      // PHASE489: minimal state-aware augmentation (read-only run_view probe)";
    print "      let runSummary = \"No recent runs.\";";
    print "      try {";
    print "        const q = `SELECT run_id, task_status FROM run_view ORDER BY last_event_ts DESC LIMIT 1`;";
    print "        const r = await pool.query(q);";
    print "        if (r.rows && r.rows.length > 0) {";
    print "          const row = r.rows[0];";
    print "          runSummary = `Latest run: ${row.run_id} (${row.task_status})`;";
    print "        }";
    print "      } catch (e) {";
    print "        console.warn(\"[PHASE489] run_view probe failed\", e.message);";
    print "      }";
    print "";
    print "      console.log(\"[PHASE489_TRACE] /api/chat hit\", { agent: requestedAgent, message });";
    print "      return res.json({";
    print "        ok: true,";
    print "        agent: requestedAgent,";
    print "        mode: \"deterministic-local-response\",";
    print "        reply: `${requestedAgent.charAt(0).toUpperCase() + requestedAgent.slice(1)} received your request: \"${message}\"\\n${runSummary}`,";
    print "        meta: {";
    print "          timestamp: \"deterministic-local\",";
    print "          pipeline: \"matilda-stub\",";
    print "        },";
    print "      });";
    patched=1;
  }
  next
}
{print}
' server.mjs)
