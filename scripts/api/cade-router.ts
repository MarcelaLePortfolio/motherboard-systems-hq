import express from "express";
import { runSkill } from "../utils/runSkill";
import { generateSkillFromPrompt, createSkillDirect } from "../pipelines/skillGen";

const router = express.Router();

router.post("/run", async (req, res) => {
  try {
    const { skill, params } = req.body || {};
    if (!skill) return res.status(400).json({ ok: false, error: "Missing 'skill'." });
    const out = await runSkill(skill, params ?? {}, { actor: "matilda" });
    res.json({ ok: out.status === "success", ...out });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

router.post("/generate", async (req, res) => {
  try {
    const { prompt, name } = req.body || {};
    if (!prompt) return res.status(400).json({ ok: false, error: "Missing 'prompt'." });
    const out = await generateSkillFromPrompt(prompt, name);
    res.json({ ok: true, ...out });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

router.post("/create", async (req, res) => {
  try {
    const { name, code } = req.body || {};
    if (!name || !code) return res.status(400).json({ ok: false, error: "Missing 'name' or 'code'." });
    const out = await createSkillDirect(name, code);
    res.json({ ok: true, ...out });
  } catch (e: any) {
    res.status(500).json({ ok: false, error: e?.message ?? String(e) });
  }
});

export default router;
