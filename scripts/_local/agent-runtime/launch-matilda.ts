import express from "express";
import cors from "cors";
import { router as matildaRouter } from "../../../routes/matilda";

const PORT = 3001;
const app = express();

app.use(cors());
app.use(express.json());   // <-- replaces body-parser

// Mount the REAL Matilda router
app.use("/matilda", matildaRouter);

app.listen(PORT, () => {
  console.log(`💛 Matilda (full router) live on port ${PORT}`);
});
