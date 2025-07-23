import { useEffect, useRef, useState } from "react";

export default function ChatbotWrapper() {
  const [messages, setMessages] = useState<string[]>([]);
  const [input, setInput] = useState("");
  const chatContainerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (chatContainerRef.current) {
      chatContainerRef.current.scrollTop = chatContainerRef.current.scrollHeight;
    }
  }, [messages]);

  const handleSend = () => {
    if (input.trim() === "") return;
    setMessages([...messages, input]);
    setInput("");
  };

  return (
    <div style={{
      border: "1px solid #ccc",
      borderRadius: "12px",
      padding: "1rem",
      backgroundColor: "#f8f8f8",
      maxHeight: "300px",
      overflow: "hidden",
      display: "flex",
      flexDirection: "column"
    }}>
      <div
        ref={chatContainerRef}
        style={{
          flex: 1,
          overflowY: "auto",
          marginBottom: "1rem",
          padding: "0.5rem",
          backgroundColor: "#fff",
          borderRadius: "8px"
        }}
      >
        {messages.map((msg, idx) => (
          <div key={idx} style={{ marginBottom: "0.5rem" }}>{msg}</div>
        ))}
      </div>
      <div style={{ display: "flex", gap: "0.5rem" }}>
        <input
          style={{ flex: 1, padding: "0.5rem", borderRadius: "6px", border: "1px solid #ccc" }}
          type="text"
          placeholder="Type here..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && handleSend()}
        />
        <button
          onClick={handleSend}
          style={{
            padding: "0.5rem 1rem",
            backgroundColor: "#4f46e5",
            color: "white",
            border: "none",
            borderRadius: "6px",
            cursor: "pointer"
          }}
        >
          Send
        </button>
      </div>
    </div>
  );
}
