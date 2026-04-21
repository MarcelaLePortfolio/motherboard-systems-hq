import express, { type Request, type Response } from "express";
import path from "path";
import cors from "cors";

const app = express();
const PORT = 3001;
const RUNTIME_ORIGIN = process.env.RUNTIME_ORIGIN || "http://127.0.0.1:8080";

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.text({ type: ["text/*", "application/xml", "application/x-www-form-urlencoded"] }));

const publicPath = path.join(process.cwd(), "public");

// Serve static assets, but do not implicitly serve index.html for "/"
app.use(express.static(publicPath, { index: false }));

function buildMatildaReply(message: unknown): string {
  const text = typeof message === "string" ? message.trim() : "";

  if (!text) return "Hi, I’m Matilda. I’m online in a local safe mode right now.";

  const lower = text.toLowerCase();

  if (["hi", "hello", "hey"].includes(lower)) {
    return "Hi, I’m Matilda. I’m online and responding in local safe mode.";
  }

  if (lower.includes("status")) {
    return "I’m here in local safe mode. Full wiring pending.";
  }

  return `I received: "${text}". Local safe mode active.`;
}

app.post("/matilda", async (req: Request, res: Response) => {
  try {
    const reply = buildMatildaReply(req.body?.message);
    res.json({ reply });
  } catch (err: any) {
    res.status(500).json({ error: "Matilda is unreachable", detail: err?.message || String(err) });
  }
});

function buildUpstreamUrl(req: Request): string {
  const original = req.originalUrl || req.url || "/";
  return `${RUNTIME_ORIGIN}${original}`;
}

async function proxy(req: Request, res: Response) {
  try {
    const url = buildUpstreamUrl(req);

    const headers: Record<string, string> = {};
    const contentType = req.headers["content-type"];
    if (typeof contentType === "string" && contentType.trim()) {
      headers["Content-Type"] = contentType;
    }
    const accept = req.headers["accept"];
    if (typeof accept === "string" && accept.trim()) {
      headers["Accept"] = accept;
    }

    let body: string | undefined;
    if (!["GET", "HEAD"].includes(req.method.toUpperCase())) {
      if (typeof req.body === "string") {
        body = req.body;
      } else if (req.body !== undefined && req.body !== null) {
        body = JSON.stringify(req.body);
        if (!headers["Content-Type"]) {
          headers["Content-Type"] = "application/json";
        }
      }
    }

    const upstream = await fetch(url, {
      method: req.method,
      headers,
      body,
    });

    res.status(upstream.status);

    upstream.headers.forEach((value, key) => {
      if (key.toLowerCase() === "transfer-encoding") return;
      res.setHeader(key, value);
    });

    const upstreamType = upstream.headers.get("content-type") || "";
    if (upstreamType.includes("text/event-stream")) {
      res.setHeader("Content-Type", "text/event-stream");
      res.setHeader("Cache-Control", "no-cache");
      res.setHeader("Connection", "keep-alive");

      const reader = upstream.body?.getReader();
      if (!reader) {
        res.end();
        return;
      }

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        res.write(Buffer.from(value));
      }

      res.end();
      return;
    }

    const buffer = Buffer.from(await upstream.arrayBuffer());
    res.send(buffer);
  } catch (err: any) {
    res.status(502).json({
      error: "proxy_failed",
      detail: err?.message || String(err),
    });
  }
}

app.use("/api", proxy);
app.use("/diagnostics", proxy);

app.get("/events/task-events", proxy);
app.get("/events/operator-guidance", proxy);
app.get("/events/ops", proxy);
app.get("/events/reflections", proxy);

app.get("/", (_req, res) => {
  res.sendFile(path.join(publicPath, "index.html"));
});

app.listen(PORT, () => {
  console.log(`Dashboard running at http://localhost:${PORT}`);
  console.log(`Proxying API/SSE → ${RUNTIME_ORIGIN}`);
});
