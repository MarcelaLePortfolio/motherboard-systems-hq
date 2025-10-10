 
import React, { useState } from 'react';

const ChatConsole: React.FC = () => {
  const [messages, setMessages] = useState([
    { role: 'user', text: "What’s the status of our marketing campaign?" },
    { role: 'agent', text: 'Our marketing campaign is still in progress.' },
  ]);
  const [input, setInput] = useState('');

  const sendMessage = () => {
    if (!input.trim()) return;
    setMessages([...messages, { role: 'user', text: input }]);
    setInput('');
  };

  return (
    <div style={{
      background: '#fafafa',
      borderRadius: '16px',
      padding: '24px',
      marginBottom: '32px',
      boxShadow: '0 0 12px rgba(0,0,0,0.06)',
    }}>
      {messages.map((msg, i) => (
        <div
          key={i}
          style={{
            backgroundColor: msg.role === 'user' ? '#f1f1f1' : '#e6eeff',
            padding: '16px',
            borderRadius: '12px',
            marginBottom: '12px',
            color: '#111',
            fontSize: '18px',
            fontWeight: 500,
          }}
        >
          {msg.text}
        </div>
      ))}
      <div style={{ display: 'flex', alignItems: 'stretch', marginTop: '8px' }}>
        <input
          type="text"
          placeholder="Send a message..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
          style={{
            flex: 1,
            padding: '16px',
            borderTopLeftRadius: '8px',
            borderBottomLeftRadius: '8px',
            border: '1px solid #ccc',
            fontSize: '16px',
            outline: 'none',
          }}
        />
        <button
          onClick={sendMessage}
          style={{
            background: '#5c3bfe',
            color: 'white',
            padding: '0 20px',
            fontSize: '18px',
            borderTopRightRadius: '8px',
            borderBottomRightRadius: '8px',
            border: 'none',
            cursor: 'pointer',
          }}
        >📩</button>
      </div>
    </div>
  );
};

export default ChatConsole;
