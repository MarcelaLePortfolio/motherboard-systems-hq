import request from "supertest";
import { app } from "../../server/app";

describe("GET /api/runs", () => {
  it("returns 200 and array", async () => {
    const res = await request(app).get("/api/runs");
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });
});
