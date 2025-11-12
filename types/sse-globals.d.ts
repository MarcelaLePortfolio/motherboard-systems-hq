// Global stubs for SSE/Express compilation
declare global {
  class Client {
    write(...args: any[]): void;
    on(...args: any[]): void;
  }

  const clients: Client[];

  const res: {
    write(...args: any[]): void;
    setHeader(...args: any[]): void;
    flushHeaders(): void;
    on(...args: any[]): void;
  };

  const req: {
    on(...args: any[]): void;
  };
}
export {};
