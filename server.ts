import express, { Request, Response } from "express";
import path from "path";
import crypto from "crypto";
import { fileURLToPath } from "url";
import { dirname } from "path";
import { handleMatildaMessage } from "./scripts/agents/matilda-handler";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
app.use(express.json());
app.use(express.static(path.join(process.cwd(), "public")));

console.log("▶️ Running server from:", __filename);
console.log("▶️ CWD:", process.cwd());

function parseCookies(cookieHeader?: string): Record<string, string> {
  const out: Record<string, string> = {};
  if (!cookieHeader) return out;
  cookieHeader.split(";").forEach((part) => {
    const [k, v] = part.split("=").map((s) => s.trim());
    if (k && v) out[k] = decodeURIComponent(v);
  });
  return out;
}
function getOrCreateSid(req: Request, res: Response): string {
  const cookies = parseCookies(req.headers.cookie);
  let sid = cookies["sid"];
  if (!sid) {
    sid = crypto.randomUUID();
    res.setHeader("Set-Cookie", `sid=${encodeURIComponent(sid)}; Path=/; HttpOnly`);
  }
  return sid;
}

app.get("/health", (_req, res) => res.json({ ok: true }));

// 🔎 Simple echo test
app.post("/echo", (req: Request, res: Response) => {
  console.log("📩 Hit /echo:", req.body);
  res.json({ you_said: req.body });
});

// Matilda route
app.post("/matilda", async (req: Request, res: Response) => {
  console.log("📩 Hit /matilda route with body:", req.body);
  try {
    const { message } = req.body || {};
    if (!message || typeof message !== "string") {
      return res.status(400).json({ replies: ["⚠️ Missing message"] });
    }
    const sid = getOrCreateSid(req, res);
    const result = await handleMatildaMessage(sid, message);
    console.log("📤 Matilda replied:", result);
    return res.json({ replies: result.replies ?? [] });
  } catch (err: any) {
    console.error("❌ Matilda route error:", err);
    return res.status(500).json({ replies: ["⚠️ " + (err?.message || "Matilda failed")] });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Server listening on http://localhost:${PORT}`);
  console.log("Mounted: GET /health, POST /echo, POST /matilda, static /public");
});
