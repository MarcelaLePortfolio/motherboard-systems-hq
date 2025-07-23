import { useState } from "react";

export default function Chatbot() {
  const [messages, setMessages] = useState<string[]>([]);
  const [input, setInput] = useState("");

  function handleSend() {
    if (!input.trim()) return;
    setMessages([...messages, input]);
    setInput("");
  }

  return (
    <div style={{
      background: "#f4f4f4",
      borderRadius: "1rem",
      padding: "1rem",
      maxHeight: "400px",
      overflowY: "auto",
      display: "flex",
      flexDirection: "column",
      gap: "1rem",
    }}>
      <div style={{ flex: 1, overflowY: "auto" }}>
        {messages.map((msg, idx) => (
          <div key={idx} style={{ background: "#fff", padding: "0.5rem", borderRadius: "0.5rem" }}>
            {msg}
          </div>
        ))}
      </div>
      <div style={{ display: "flex", gap: "0.5rem" }}>
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => { if (e.key === "Enter") handleSend(); }}
          placeholder="Type your message..."
          style={{ flex: 1, padding: "0.5rem", borderRadius: "0.5rem", border: "1px solid #ccc" }}
        />
        <button onClick={handleSend} style={{ padding: "0.5rem 1rem", borderRadius: "0.5rem", background: "#222", color: "#fff" }}>
          Send
        </button>
      </div>
    </div>
  );
}
