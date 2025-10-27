import express from "express";
import { runSkill } from "../scripts/utils/runSkill";
import { broadcast } from "../server";

export const router = express.Router();

router.post("/", async (req, res) => {
  try {
    const { message } = req.body;
    console.log("💬 Matilda received:", message);

    if (message.includes("create file")) {
      const filename = message.replace("create file", "").trim() || "newfile";
      const result = await runSkill("createFile", { filename });
      broadcast(`Matilda→Cade delegation success: ${result}`);
      return res.json({ message: result });
    }

    const response = "🤖 Matilda: no matching skill detected.";
    broadcast(response);
    return res.json({ message: response });
  } catch (err) {
    const errorMsg = `❌ Matilda encountered an error: ${err.message}`;
    console.error(errorMsg);
    broadcast(errorMsg);
    return res.json({ message: errorMsg });
  }
});
