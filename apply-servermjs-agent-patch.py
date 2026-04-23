from pathlib import Path
import sys

path = Path("server.mjs")
text = path.read_text()

old = '''app.post("/api/chat", async (req, res) => {
  try {
    const rawMessage =
      req.body?.message ??
      req.body?.prompt ??
      req.body?.text ??
      "";

    const message = String(rawMessage || "").replace(/\\s+/g, " ").trim();

    if (!message) {
      return res.status(400).json({
        ok: false,
        agent: "matilda",
        mode: "deterministic-local-response",
        error: "Missing or invalid 'message' in request body.",
      });
    }

    return res.json({
      ok: true,
      agent: "matilda",
      mode: "deterministic-local-response",
      message,
      reasoning: [
        "Agent selected: matilda",
        `Message length: ${message.length}`,
        "Mode: deterministic local response layer",
        "External runtime: disabled",
        "Execution class: UI-safe acknowledgement",
      ].join(" | "),
      reply: [
        "Matilda received your request.",
        `Input: \\"${message}\\"`,
        "Status: deterministic local response active.",
        "Runtime handoff: not enabled in this corridor.",
        "Next step: provide a specific task or request an auditable system action.",
      ].join("\\n"),
      meta: {
        timestamp: "deterministic-local",
        pipeline: "matilda-stub",
      },
    });
  } catch (error) {
    return res.status(500).json({
      ok: false,
      agent: "matilda",
      mode: "deterministic-local-response",
      error: error instanceof Error ? error.message : "Unknown chat stub error",
    });
  }
});'''

new = '''app.post("/api/chat", async (req, res) => {
  try {
    const rawMessage =
      req.body?.message ??
      req.body?.prompt ??
      req.body?.text ??
      "";
    const requestedAgent = String(req.body?.agent || "matilda").trim().toLowerCase() || "matilda";

    const message = String(rawMessage || "").replace(/\\s+/g, " ").trim();

    if (!message) {
      return res.status(400).json({
        ok: false,
        agent: requestedAgent,
        mode: "deterministic-local-response",
        error: "Missing or invalid 'message' in request body.",
      });
    }

    return res.json({
      ok: true,
      agent: requestedAgent,
      mode: "deterministic-local-response",
      message,
      reasoning: [
        `Agent selected: ${requestedAgent}`,
        `Message length: ${message.length}`,
        "Mode: deterministic local response layer",
        "External runtime: disabled",
        "Execution class: UI-safe acknowledgement",
      ].join(" | "),
      reply: [
        `${requestedAgent.charAt(0).toUpperCase() + requestedAgent.slice(1)} received your request.`,
        `Input: \\"${message}\\"`,
        "Status: deterministic local response active.",
        "Runtime handoff: not enabled in this corridor.",
        "Next step: provide a specific task or request an auditable system action.",
      ].join("\\n"),
      meta: {
        timestamp: "deterministic-local",
        pipeline: "matilda-stub",
      },
    });
  } catch (error) {
    return res.status(500).json({
      ok: false,
      agent: String(req.body?.agent || "matilda").trim().toLowerCase() || "matilda",
      mode: "deterministic-local-response",
      error: error instanceof Error ? error.message : "Unknown chat stub error",
    });
  }
});'''

if old not in text:
    print("ERROR: expected /api/chat block not found exactly; aborting.")
    sys.exit(1)

path.write_text(text.replace(old, new, 1))
print("PATCHED: server.mjs")
