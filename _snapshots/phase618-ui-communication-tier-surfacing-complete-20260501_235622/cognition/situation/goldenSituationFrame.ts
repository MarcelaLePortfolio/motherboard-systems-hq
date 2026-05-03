import type { SituationFrame } from "./situationFrame.types.ts";

export interface GoldenSituationFrame {

  title:string;

  summary:string;

  attentionLevel:"LOW" | "MEDIUM" | "HIGH";

  facts?:Record<string,string>;

}

function normalizeFacts(
  context?:Record<string,unknown>
):Record<string,string>|undefined{

  if(!context) return undefined;

  const facts:Record<string,string> = {};

  for(const [k,v] of Object.entries(context)){

    if(v === undefined || v === null) continue;

    if(typeof v === "string"){

      const trimmed = v.trim();

      if(trimmed.length === 0) continue;

      facts[k] = trimmed;

      continue;
    }

    if(typeof v === "number" || typeof v === "boolean"){

      facts[k] = String(v);

      continue;
    }

    facts[k] = JSON.stringify(v);
  }

  return Object.keys(facts).length > 0
    ? facts
    : undefined;
}

export function toGoldenSituationFrame(
  frame:SituationFrame
):GoldenSituationFrame{

  return {

    title:frame.title,

    summary:frame.summary,

    attentionLevel:frame.attentionLevel,

    facts:normalizeFacts(
      frame.context
    )

  };
}
