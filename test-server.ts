import express from "express";

const app = express();
app.use(express.json());

app.get("/ping", (_req, res) => res.json({ pong: true }));
app.post("/echo", (req, res) => res.json({ you: req.body }));

const PORT = 4000;
app.listen(PORT, () => console.log(`✅ Test server listening on http://localhost:${PORT}`));
