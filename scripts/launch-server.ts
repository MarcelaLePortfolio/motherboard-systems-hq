// <0001fb31> Canonical Express launcher (single unified app)
import app from "../server";

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Launch server listening on http://localhost:${PORT}`);
});
