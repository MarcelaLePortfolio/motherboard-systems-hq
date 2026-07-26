import { useContext } from "react";
import { MatildaConversationContext } from "./MatildaConversationProvider";

export function useMatildaConversation() {
  const context = useContext(MatildaConversationContext);

  if (!context) {
    throw new Error(
      "useMatildaConversation must be used within a MatildaConversationProvider"
    );
  }

  return context;
}
