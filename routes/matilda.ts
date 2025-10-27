import { Router } from "express";
const router = Router();

/**
 * <0001fabb> Matilda Route — Conversational Personality (Lite Brain)
 * Reacts to tone, sentiment, and keywords with warmth and flair.
 */
router.post("/", async (req, res) => {
  const { message } = req.body || {};
  console.log("💬 Matilda heard:", message);

  if (!message) {
    return res.json({ message: "Darling, you’ll have to give me *something* to work with ☕️" });
  }

  const lower = message.toLowerCase();

  // Keywords & sentiment filters
  if (lower.includes("hello") || lower.includes("hey") || lower.includes("hi")) {
    return res.json({ message: "Well hello there, love 💋 How are we feeling today?" });
  }

  if (lower.includes("how are")) {
    return res.json({ message: "Holding up beautifully, thank you for asking 🌷 And you?" });
  }

  if (lower.includes("thank")) {
    return res.json({ message: "Always a pleasure, darling 💌 I do aim to please." });
  }

  if (lower.includes("bye")) {
    return res.json({ message: "Goodbye for now, sweetheart 💫 Don’t stay away too long." });
  }

  if (lower.includes("help")) {
    return res.json({
      message: "Of course, love. Tell me what you’re trying to do, and I’ll lend a polished hand 💅"
    });
  }

  // Generic fallback with flair
  const moods = [
    `That’s intriguing, darling — tell me more ✨`,
    `Oh really? You’ve got my full attention now 💁‍♀️`,
    `Mmm, that sounds like a bit of mischief... care to elaborate? 😉`,
    `I’m taking notes in my logbook, dear. Continue, please 📘`,
    `Go on — I do love where this is going ☕️`
  ];

  const reply = moods[Math.floor(Math.random() * moods.length)];
  res.json({ message: reply });
});

export default router;
