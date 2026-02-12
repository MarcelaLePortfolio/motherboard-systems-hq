import express from "express";
import { getRunsList } from "./routes/api_runs_list";

export const app = express();

app.get("/api/runs", getRunsList);
