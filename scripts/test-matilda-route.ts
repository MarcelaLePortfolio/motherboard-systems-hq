import fetch from "node-fetch";

(async () => {
  try {
    const res = await fetch("http://localhost:3000/matilda", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message: "Hello Matilda from route test" })
    });
    console.log("Status:", res.status);
    const text = await res.text();
    console.log("Raw response:", text);
  } catch (err) {
    console.error("Request failed:", err);
  }
})();
