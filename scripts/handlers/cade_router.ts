import { generateFileWithOllama } from "../agents/handlers/generateFileWithOllama";
import { summarizeWithOllama } from "../agents/handlers/summarizeWithOllama";
import { explainCodeWithOllama } from "../agents/handlers/explainCodeWithOllama";
import { commentCodeWithOllama } from "../agents/handlers/commentCodeWithOllama";
import { refactorCodeWithOllama } from "../agents/handlers/refactorCodeWithOllama";
import { formatCommentsWithOllama } from "../agents/handlers/formatCommentsWithOllama";
import { translateCodeWithOllama } from "../agents/handlers/translateCodeWithOllama";
import { convertCodeWithOllama } from "../agents/handlers/convertCodeWithOllama";

export async function cadeCommandRouter(command: string, args?: any) {
  switch (command) {
    case "infer agent": {
      console.log("🕵️ (Stub) Inferring agent from file:", args?.path);
      return { status: "success", agent: "Cade (inferred stub)" };
    }

    case "generate": {
      return await generateFileWithOllama(args);
    }

    case "commit": {
      const msg = args?.message || "📦 Default commit message";
      console.log(`💾 (Stub) Committing with message: "${msg}"`);
      return { status: "success", message: `Committed with: ${msg}` };
    }

    case "summarize": {
      return await summarizeWithOllama(args);
    }
    case "explain": {
      return await explainCodeWithOllama(args);
    }
    case "comment": {
      return await commentCodeWithOllama(args);
    }
    case "refactor": {
      return await refactorCodeWithOllama(args);
    }
    case "format": {
      return await formatCommentsWithOllama(args);
    }
    case "translate": {
      return await translateCodeWithOllama(args);
    }
    case "convert": {
      return await convertCodeWithOllama(args);
    }

    default:
      return { status: "error", message: `Unknown command: ${command}` };
  }
}