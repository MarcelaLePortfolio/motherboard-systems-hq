import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";

// Bootstrap only. No routing, no data fetching, no global state
// is wired up here. This file's only job is mounting the shell.
const rootElement = document.getElementById("root");

if (!rootElement) {
  throw new Error("Bootstrap failed: #root element not found in index.html");
}

ReactDOM.createRoot(rootElement).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
