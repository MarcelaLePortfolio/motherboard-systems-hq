// Stub methods for streaming clients
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
