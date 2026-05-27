import express from "express";
import path from "path";
import cors from "cors";
const app = express();
const PORT = 3000;
app.use(cors());
app.use(express.static(path.join(process.cwd(), "public")));
app.get("/", (req, res) => res.redirect("/dashboard.html"));
app.listen(PORT, () => console.log(`✅ Dev server running at http://localhost:${PORT}`));
