const serve = require("serve");
const http = require("http");
const { parse } = require("url");
const path = require("path");

// Serve the public folder
const serveHandler = serve(path.join(process.cwd(), "public"), { single: true });

const server = http.createServer((req, res) => {
  const parsedUrl = parse(req.url, true);
  if (parsedUrl.pathname === "/health") req.url = "/health.html";
  serveHandler(req, res);
});

const port = 3000;
server.listen(port, () => console.log(`Server running at http://localhost:${port}`));
