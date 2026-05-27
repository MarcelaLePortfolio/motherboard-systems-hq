// Treat all SSE / Express objects as any for compilation
declare const res: any;
declare const req: any;
declare const clients: any;
declare class Client { write(...args: any[]): void; on(...args: any[]): void; }
