import React, { useState } from "react";

const ChatInterface: React.FC = () => {
  const [messages, setMessages] = useState<{ role: string; content: string }[]>([
    {
      role: "assistant",
      content: "Our marketing campaign is still in progress.",
    },
  ]);
  const [input, setInput] = useState("");

  const sendMessage = () => {
    if (!input.trim()) return;
    setMessages([...messages, { role: "user", content: input }]);
    setInput("");
    setTimeout(() => {
      setMessages((prev) => [
        ...prev,
        {
          role: "assistant",
          content: "Our marketing campaign is still in progress.",
        },
      ]);
    }, 500);
  };

  return (
    <div style={{
      background: "white",
      borderRadius: "1rem",
      boxShadow: "0 0 0 1px #e0e0e0",
      padding: "1rem",
      marginBottom: "2rem",
      maxWidth: "100%",
    }}>
      <div>
        {messages.map((msg, idx) => (
          <div
            key={idx}
            style={{
              backgroundColor: msg.role === "assistant" ? "#e6f0ff" : "#f3f3f3",
              padding: "0.75rem 1rem",
              marginBottom: "0.5rem",
              borderRadius: "0.5rem",
              fontWeight: msg.role === "user" ? "500" : "normal",
            }}
          >
            {msg.content}
          </div>
        ))}
      </div>
      <div style={{ display: "flex", marginTop: "1rem", alignItems: "center" }}>
        <input
          type="text"
          placeholder="Send a message..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter") sendMessage();
          }}
          style={{
            flexGrow: 1,
            padding: "0.75rem",
            fontSize: "1rem",
            border: "1px solid #ccc",
            borderRadius: "0.5rem 0 0 0.5rem",
          }}
        />
        <button
          onClick={sendMessage}
          style={{
            backgroundColor: "#5f2eff",
            color: "white",
            padding: "0.75rem 1rem",
            border: "none",
            borderRadius: "0 0.5rem 0.5rem 0",
            cursor: "pointer",
            display: "flex",
            alignItems: "center",
            justifyContent: "center"
          }}
        >
          📩
        </button>
      </div>
    </div>
  );
};

export default ChatInterface;
