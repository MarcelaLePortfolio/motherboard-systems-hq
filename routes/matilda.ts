import express from "express";
import { ollamaPlan } from "../scripts/utils/ollamaPlan";
import { runSkill } from "../scripts/utils/runSkill";
import { spawn } from "child_process";

export const router = express.Router();

// Flexible Atlas trigger detection
const atlasTriggers: RegExp[] = [
  /create (a )?new agent called atlas/i,
  /new agent named atlas/i,
  /spin up atlas/i,
  /bring atlas online/i,
  /atlas\b.*project director/i,
  /project director\b.*atlas/i
];

function shouldTriggerAtlas(message: string): boolean {
  return atlasTriggers.some((re) => re.test(message));
}

router.post("/", async (req, res) => {
  const raw = req.body?.message || "";
  const message = String(raw);

  if (!message.trim()) {
    return res.status(400).json({ message: "Matilda needs a message to work with." });
  }

  try {
    const lower = message.toLowerCase();

    // 1) Atlas live build trigger
    if (shouldTriggerAtlas(message)) {
      console.log("<0001fa9f> 🛰 Matilda detected Atlas creation intent from chat input.");

      const child = spawn(
        "npx",
        ["tsx", "scripts/sequences/atlas-build-sequence.ts"],
        { stdio: "inherit", shell: true }
      );

      child.on("error", (err) => {
        console.error("❌ Atlas build sequence failed to start:", err);
      });

      child.on("exit", (code) => {
        if (code === 0) {
          console.log("<0001fa9f> ✅ Atlas build sequence completed successfully.");
        } else {
          console.error(`<0001fa9f> ⚠️ Atlas build sequence exited with code ${code}`);
        }
      });

      return res.json({
        reply:
          "Understood. I’ll begin constructing Atlas as our project director now. " +
          "Watch the Recent Logs panel for live build updates as the system comes online."
      });
    }

    // 2) Delegation trigger (existing behavior)
    const delegationTriggers = ["create", "read", "delete", "run", "execute", "write"];
    const shouldDelegate = delegationTriggers.some((t) => lower.includes(t));

    if (shouldDelegate) {
      const result = await runSkill("delegate");
      console.log(`<0001f9e0> Matilda delegated task based on: ${message}`);
      return res.json({ message: result });
    }

    // 3) Default: Matilda via ollamaPlan
    console.log(`<0001fa9f> 📨 Matilda received message: ${message}`);
    const response = await ollamaPlan(message);
    console.log(`💬 Matilda responded: ${response}`);

    return res.json({ message: response });
  } catch (err: any) {
    console.error("❌ Matilda error:", err);
    return res.status(500).json({
      message: "Matilda encountered an error while processing that."
    });
  }
});
