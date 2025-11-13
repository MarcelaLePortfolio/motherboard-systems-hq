import express from "express";
import fs from "fs";
import path from "path";
import { ollamaChat } from "../scripts/utils/ollamaChat.ts";

export const router = express.Router();

// ==============================================
// 🔧 Minimal Skill: Create HTML File Directly
// ==============================================
async function createHtmlFile(filename: string, html: string) {
  const targetPath = path.join(process.cwd(), "public", filename);

  try {
    fs.writeFileSync(targetPath, html, "utf8");
    console.log(`<0001fb40> 📝 File created: ${targetPath}`);
    return { ok: true, path: targetPath };
  } catch (err) {
    console.error("<0001fb40> ❌ File creation failed:", err);
    return { ok: false, error: err };
  }
}

// ==============================================
// 🎯 Delegation Parser (simple version)
// Example message:
// “Matilda, create a webpage called mean-girls.html with <html>...</html>”
// ==============================================
function parseDelegationMessage(msg: string) {
  const filenameMatch = msg.match(/called\s+([\w\-\.]+\.html)/i);
  const htmlMatch = msg.match(/```html([\s\S]*?)```/i);

  const filename = filenameMatch ? filenameMatch[1] : null;
  const html = htmlMatch ? htmlMatch[1].trim() : null;

  return { filename, html };
}

// ==============================================
// 🧠 Matilda Main Route
// ==============================================
router.post("/", async (req, res) => {
  const { message, delegate } = req.body;

  console.log("<0001fa9f> 📨 Matilda received:", { message, delegate });

  try {
    // ======================================
    // 🚀 Delegation Path
    // ======================================
    if (delegate) {
      const { filename, html } = parseDelegationMessage(message);

      if (!filename || !html) {
        return res.json({
          message:
            "⚠️ Delegation received, but I couldn't detect a filename or HTML block. Please include something like:\n\n```html\n<html>...</html>\n```",
        });
      }

      const result = await createHtmlFile(filename, html);

      if (result.ok) {
        return res.json({
          message:
            `🚀 Delegation completed!\n\nCreated **${filename}** in /public.\nYou can open it now.`,
        });
      }

      return res.json({
        message: `❌ Delegation failed:\n${result.error}`,
      });
    }

    // ======================================
    // 💬 Normal Chat Path
    // ======================================
    const start = Date.now();
    const reply = await ollamaChat(message);
    const elapsed = ((Date.now() - start) / 1000).toFixed(2);

    console.log(`<0001fa9f> 🕒 Matilda chat time: ${elapsed}s`);
    return res.json({ message: reply });

  } catch (err) {
    console.error("<0001fab5> ❌ Matilda error:", err);
    return res.status(500).json({ error: "Internal Matilda error" });
  }
});
