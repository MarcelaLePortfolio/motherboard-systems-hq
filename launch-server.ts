// <0001fae5> Unified Express launcher — uses shared app from server.ts
import app from "./server";
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Unified Express instance listening on http://localhost:${PORT}`);
});
