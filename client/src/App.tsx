import { ProjectContextProvider } from "./project-context/ProjectContextProvider";
import { MatildaConversationProvider } from "./matilda-chat/MatildaConversationProvider";
import Shell from "./shell/Shell";

// Global application frame for this corridor. Intentionally thin:
// its only responsibility is hosting the Shell within the shared
// Project Context lifecycle. It does not decide navigation or
// interpret project state.
//
// MatildaConversationProvider is mounted inside ProjectContextProvider
// because the conversation lifecycle is project-scoped: it reads the
// active project id via useProjectContext and must re-key its state
// whenever the active project changes.
export default function App() {
  return (
    <ProjectContextProvider>
      <MatildaConversationProvider>
        <Shell />
      </MatildaConversationProvider>
    </ProjectContextProvider>
  );
}
