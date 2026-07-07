import express from "express";

export const router = express.Router();

router.post("/matilda", async (req, res) => {
  const message = req.body.message;
  let reply = "…unknown error…";

  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${process.env.OPENAI_API_KEY}`
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: "You are Matilda, the delegation orchestrator." },
          { role: "user", content: message }
        ]
      })
    }).then(r => ron());

    reply = response?.choices?.[0]?.message?.content || "(no reply)";
  } catch (err:any) {
    reply = `(matilda error: ${(err as any).message})`;
  }

  return reson({ reply });
});
