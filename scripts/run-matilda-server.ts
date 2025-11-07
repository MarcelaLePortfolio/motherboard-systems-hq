// <0001fae7> Phase 9.0 — Matilda Server Standalone Bootstrap
import express from "express";
import { router as matildaRouter } from "../routes/matilda";

const app = express();
app.use(express.json());
app.use("/matilda", matildaRouter);

const PORT = 3001;
app.listen(PORT, () => {
  console.log(`�� Matilda API server online at http://localhost:${PORT}`);
});
