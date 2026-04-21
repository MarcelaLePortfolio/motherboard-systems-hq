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
app.use(express.static(publicPath));

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
  } catch {
    res.status(500).json({ error: "Matilda is unreachable" });
  }
});

/**
 * SIMPLE PROXY — forwards API + SSE to runtime (8080)
 */
async function proxy(req: Request, res: Response, targetPath: string) {
  try {
    const url = `${RUNTIME_ORIGIN}${targetPath}${req.url.includes("?") ? req.url.slice(req.url.indexOf("?")) : ""}`;

    const upstream = await fetch(url, {
      method: req.method,
      headers: {
        "Content-Type": req.headers["content-type"] || "application/json",
      },
      body: ["GET", "HEAD"].includes(req.method) ? undefined : JSON.stringify(req.body),
    });

    res.status(upstream.status);

    upstream.headers.forEach((value, key) => {
      if (key.toLowerCase() === "transfer-encoding") return;
      res.setHeader(key, value);
    });

    const contentType = upstream.headers.get("content-type") || "";

    if (contentType.includes("text/event-stream")) {
      res.setHeader("Content-Type", "text/event-stream");
      res.setHeader("Cache-Control", "no-cache");
      res.setHeader("Connection", "keep-alive");

      const reader = upstream.body?.getReader();
      if (!reader) return res.end();

      async function pump() {
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          res.write(Buffer.from(value));
        }
        res.end();
      }

      pump();
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

// API routes
app.use("/api", (req, res) => proxy(req, res, "/api"));
app.use("/diagnostics", (req, res) => proxy(req, res, "/diagnostics"));

// SSE routes
app.get("/events/task-events", (req, res) => proxy(req, res, "/events/task-events"));
app.get("/events/operator-guidance", (req, res) => proxy(req, res, "/events/operator-guidance"));
app.get("/events/ops", (req, res) => proxy(req, res, "/events/ops"));
app.get("/events/reflections", (req, res) => proxy(req, res, "/events/reflections"));

// Root
app.get("/", (_req, res) => {
  res.sendFile(path.join(publicPath, "dashboard.html"));
});

app.listen(PORT, () => {
  console.log(`Dashboard running at http://localhost:${PORT}`);
  console.log(`Proxying API/SSE → ${RUNTIME_ORIGIN}`);
});
