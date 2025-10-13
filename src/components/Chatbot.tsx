 
import { useState, useRef, useEffect } from "react";

export default function Chatbot() {
  const [messages, setMessages] = useState<string[]>([]);
  const [input, setInput] = useState("");
  const messagesEndRef = useRef<HTMLDivElement>(null);

  function handleSend() {
    if (!input.trim()) return;
    setMessages([...messages, input]);
    setInput("");
  }

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  return (
    <div style={{
      background: "#f2f2f2",
      border: "1px solid #ccc",
      borderRadius: "12px",
      padding: "1rem",
      height: "300px",
      display: "flex",
      flexDirection: "column",
      overflow: "hidden"
    }}>
      <div style={{
        flex: 1,
        overflowY: "auto",
        marginBottom: "0.75rem",
        paddingRight: "0.5rem"
      }}>
        {messages.map((msg, idx) => (
          <div key={idx} style={{
            background: "#fff",
            padding: "0.5rem 0.75rem",
            borderRadius: "8px",
            marginBottom: "0.5rem"
          }}>
            {msg}
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>
      <div style={{ display: "flex", gap: "0.5rem" }}>
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => { if (e.key === "Enter") handleSend(); }}
          placeholder="Type a message..."
          style={{
            flex: 1,
            padding: "0.5rem",
            borderRadius: "8px",
            border: "1px solid #ccc"
          }}
        />
        <button
          onClick={handleSend}
          style={{
            padding: "0.5rem 1rem",
            background: "#222",
            color: "#fff",
            border: "none",
            borderRadius: "8px"
          }}
        >
          Send
        </button>
      </div>
    </div>
  );
}
