import Shell from "./shell/Shell";

// Global application frame for this corridor. Intentionally thin:
// its only responsibility is hosting the Shell. It does not decide
// navigation, fetch data, or hold application state.
export default function App() {
  return <Shell />;
}
