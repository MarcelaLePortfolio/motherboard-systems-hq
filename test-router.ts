import express from "./scripts/api/express-shared";
import reflectionsRouter from "./scripts/api/reflections-router";

const app = express();
app.use("/api/reflections", reflectionsRouter);

app.listen(4000, () => console.log("🧩 Test server listening on http://localhost:4000"));
