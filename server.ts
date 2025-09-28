import express, { Request, Response } from "express";
import path from "path";
import crypto from "crypto";
import { handleMatildaMessage } from "./scripts/agents/matilda-handler";

const app = express();
app.use(express.json({ limit: "2mb" }));
app.use(express.static(path.join(process.cwd(), "public")));

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
    res.setHeader(
      "Set-Cookie",
      `sid=${encodeURIComponent(sid)}; Path=/; Max-Age=${7 * 24 * 60 * 60}; SameSite=Lax`
    );
  }
  return sid;
}

app.get("/health", (_req, res) => res.json({ ok: true }));

app.post("/matilda", async (req: Request, res: Response) => {
  try {
    const { message } = req.body || {};
    console.log("📩 Incoming /matilda:", message);

    if (!message || typeof message !== "string") {
      console.warn("⚠️ Missing or invalid message in request body");
      return res.status(400).json({ error: "Missing message" });
    }

    const sid = getOrCreateSid(req, res);
    const result = await handleMatildaMessage(sid, message);

    console.log("📤 Matilda response:", result);
    return res.json(result);
  } catch (err: any) {
    console.error("❌ Matilda route error:", err);
    return res.status(500).json({ error: err?.message || "Matilda failed" });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Server listening on http://localhost:${PORT}`);
});
