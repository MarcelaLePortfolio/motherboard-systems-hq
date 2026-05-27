// Allow TypeScript to compile demo code with SSE/Response objects
declare class Client {
  write(...args: any[]): void;
  on(...args: any[]): void;
}

declare const res: {
  write(...args: any[]): void;
  setHeader(...args: any[]): void;
  flushHeaders(): void;
  on(...args: any[]): void;
};

declare const req: {
  on(...args: any[]): void;
};

declare const clients: Client[];
