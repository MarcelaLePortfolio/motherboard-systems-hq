import { ProjectContextProvider } from "./project-context/ProjectContextProvider";
import Shell from "./shell/Shell";

// Global application frame for this corridor. Intentionally thin:
// its only responsibility is hosting the Shell within the shared
// Project Context lifecycle. It does not decide navigation or
// interpret project state.
export default function App() {
  return (
    <ProjectContextProvider>
      <Shell />
    </ProjectContextProvider>
  );
}
