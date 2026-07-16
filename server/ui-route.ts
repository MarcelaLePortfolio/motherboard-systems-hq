import path from "path";

export function registerUI(app: any) {
  app.get("/ui", (_req, res) => {
    res.sendFile(path.resolve(process.cwd(), "public/index.html"));
  });
}
