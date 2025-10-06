// <0001fad0> Entry point ensuring single Express app instance
import app from "./server";

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Unified app listening on http://localhost:${PORT}`);
});
