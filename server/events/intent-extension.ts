
export type IntentSnapshot = {

  raw: any;

  source: string;

  timestamp: number;

};

export function attachIntent(intent: any, source: string): IntentSnapshot {

  return {

    raw: intent,

    source,

    timestamp: Date.now()

  };

}

