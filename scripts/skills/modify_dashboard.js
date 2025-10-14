import fs from "fs";
import path from "path";

export default async function run(params, ctx = {}) {
  const file = path.join(process.cwd(), "public", "dashboard.html");
  let html = fs.readFileSync(file, "utf8");

  // Repair visible tasks/logs panels
  html = html.replace(/<table id="tasks"><\/table>/g,
    '<pre id="tasks">• Recent tasks will appear here...</pre>');
  html = html.replace(/<table id="logs"><\/table>/g,
    '<pre id="logs">• Recent logs will appear here...</pre>');

  fs.writeFileSync(file, html, "utf8");
  return { message: "Dashboard panels restored", file };
}
