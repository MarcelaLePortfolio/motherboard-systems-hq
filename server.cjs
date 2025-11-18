
const express = require("express");
const fs = require("fs");
const path = require("path");
const cors = require("cors");
const app = express();
const port = 4000;

// Essential Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));
// Main dashboard route handler (bypassing static middleware and serving from public)
app.get("/dashboard.html", (req, res) => {
    res.sendFile(path.join(__dirname, "public", "dashboard.html"));
});

// Start the server
app.listen(port, () => {
    console.log(`✅ Dashboard live on port ${port}`);
});

