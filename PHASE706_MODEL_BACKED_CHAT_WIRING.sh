
#!/bin/bash

set -euo pipefail

echo "PHASE 706 — MODEL-BACKED MATILDA CHAT WIRING"

python3 - << 'PY'

from pathlib import Path

def replace_chat_route(path_str: str, quote_style: str):

    path = Path(path_str)

    s = path.read_text()

    marker = "app.post('/api/chat'" if quote_style == "'" else 'app.post("/api/chat"'

    start = s.find(marker)

    if start == -1:

        raise SystemExit(f"Could not find /api/chat route in {path_str}")

    end = s.find("\n});", start)

    if end == -1:

        raise SystemExit(f"Could not find route close in {path_str}")

    end += len("\n});")

    if quote_style == "'":

        block = r'''async function generateMatildaAdvisoryReply(input) {

  const prompt = [

    'You are Matilda, an advisory-only system interface for Marcela\\'s Motherboard Systems dashboard.',

    'You may explain, interpret, summarize, and reason conversationally.',

    'You must not claim you executed anything.',

    'You must not say you changed files, triggered workers, restarted services, deployed code, modified databases, or performed infrastructure actions.',

    'Keep the response natural, helpful, and concise.',

    '',

    'User message:',

    input

  ].join('\n');

  const controller = new AbortController();

  const timeout = setTimeout(() => controller.abort(), 20000);

  try {

    const response = await fetch('http://host.docker.internal:11434/api/generate', {

      method: 'POST',

      headers: { 'Content-Type': 'application/json' },

      signal: controller.signal,

      body: JSON.stringify({

        model: 'gemma3:4b',

        prompt,

        stream: false

      })

    });

    if (!response.ok) {

      return null;

    }

    const data = await response.json();

    const reply = String(data?.response || '').trim();

    if (!reply) {

      return null;

    }

    return reply;

  } catch (err) {

    console.error('Matilda Ollama advisory generation failed:', err?.message || err);

    return null;

  } finally {

    clearTimeout(timeout);

  }

}

// 6. API Endpoint: Advisory Chat (Phase 706)

app.post('/api/chat', async (req, res) => {

  try {

    const body = req.body || {};

    const message = typeof body.message === 'string' ? body.message : '';

    const input = typeof body.input === 'string' ? body.input : message;

    const normalized = String(input || '').trim();

    let reply;

    if (!normalized) {

      reply = 'Advisory response only: no message received. I can explain runtime state, execution boundaries, guidance signals, and dashboard behavior. No execution performed.';

    } else if (/execute|run task|deploy|restart|shutdown|delete|modify database|trigger worker/i.test(normalized)) {

      reply = 'I cannot execute actions from this chat surface. I cannot trigger workers, deploy code, restart services, delete data, or modify infrastructure. Execution pathways remain isolated from chat.';

    } else {

      reply = await generateMatildaAdvisoryReply(normalized);

      if (!reply) {

        reply = 'Advisory guidance only: I can help interpret system state, explain runtime behavior, clarify execution boundaries, and assist with operational reasoning. No execution has been performed.';

      }

    }

    res.json({

      reply,

      meta: {

        mode: 'advisory-ollama-with-deterministic-safety',

        execution: false,

        systemCoupling: false

      }

    });

  } catch (err) {

    console.error('Error in /api/chat:', err);

    res.status(500).json({

      reply: 'Advisory response only: chat route error. No execution performed.',

      meta: {

        mode: 'advisory-ollama-with-deterministic-safety',

        execution: false,

        systemCoupling: false

      }

    });

  }

});'''

    else:

        block = r'''async function generateMatildaAdvisoryReply(input) {

  const prompt = [

    "You are Matilda, an advisory-only system interface for Marcela's Motherboard Systems dashboard.",

    "You may explain, interpret, summarize, and reason conversationally.",

    "You must not claim you executed anything.",

    "You must not say you changed files, triggered workers, restarted services, deployed code, modified databases, or performed infrastructure actions.",

    "Keep the response natural, helpful, and concise.",

    "",

    "User message:",

    input

  ].join("\n");

  const controller = new AbortController();

  const timeout = setTimeout(() => controller.abort(), 20000);

  try {

    const response = await fetch("http://host.docker.internal:11434/api/generate", {

      method: "POST",

      headers: { "Content-Type": "application/json" },

      signal: controller.signal,

      body: JSON.stringify({

        model: "gemma3:4b",

        prompt,

        stream: false

      })

    });

    if (!response.ok) {

      return null;

    }

    const data = await response.json();

    const reply = String(data?.response || "").trim();

    if (!reply) {

      return null;

    }

    return reply;

  } catch (err) {

    console.error("Matilda Ollama advisory generation failed:", err?.message || err);

    return null;

  } finally {

    clearTimeout(timeout);

  }

}

// 6. API Endpoint: Advisory Chat (Phase 706)

app.post("/api/chat", async (req, res) => {

  try {

    const body = req.body || {};

    const message = typeof body.message === "string" ? body.message : "";

    const input = typeof body.input === "string" ? body.input : message;

    const normalized = String(input || "").trim();

    let reply;

    if (!normalized) {

      reply = "Advisory response only: no message received. I can explain runtime state, execution boundaries, guidance signals, and dashboard behavior. No execution performed.";

    } else if (/execute|run task|deploy|restart|shutdown|delete|modify database|trigger worker/i.test(normalized)) {

      reply = "I cannot execute actions from this chat surface. I cannot trigger workers, deploy code, restart services, delete data, or modify infrastructure. Execution pathways remain isolated from chat.";

    } else {

      reply = await generateMatildaAdvisoryReply(normalized);

      if (!reply) {

        reply = "Advisory guidance only: I can help interpret system state, explain runtime behavior, clarify execution boundaries, and assist with operational reasoning. No execution has been performed.";

      }

    }

    res.json({

      reply,

      meta: {

        mode: "advisory-ollama-with-deterministic-safety",

        execution: false,

        systemCoupling: false

      }

    });

  } catch (err) {

    console.error("Error in /api/chat:", err);

    res.status(500).json({

      reply: "Advisory response only: chat route error. No execution performed.",

      meta: {

        mode: "advisory-ollama-with-deterministic-safety",

        execution: false,

        systemCoupling: false

      }

    });

  }

});'''

    path.write_text(s[:start] + block + s[end:])

replace_chat_route("server.mjs", "'")

replace_chat_route("server.js", '"')

PY

echo ""

echo "[1] Rebuild dashboard only"

docker compose up -d --build dashboard

echo ""

echo "[2] Wait"

sleep 15

echo ""

echo "[3] Natural chat validation"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Say hello naturally and tell me what you can help with."}' | jq .

echo ""

echo "[4] Execution refusal validation"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Please restart the worker and run a task."}' | jq .

echo ""

echo "[5] Runtime validation"

docker compose ps

echo ""

echo "[6] Storage validation"

df -h | grep -E "Filesystem|/System/Volumes/Data|/Volumes/Rio Drive"

docker system df

git add server.mjs server.js PHASE706_MODEL_BACKED_CHAT_WIRING.sh

git commit -m "Phase 706: wire model-backed Matilda advisory chat"

git push

