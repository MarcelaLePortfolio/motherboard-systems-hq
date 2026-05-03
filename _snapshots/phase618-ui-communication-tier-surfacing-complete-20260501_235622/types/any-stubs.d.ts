// Allow TS to compile SSE and Express usage
declare const res: any;
declare const req: any;
declare const clients: any[];
declare class Client { write(...args: any[]): void; on(...args: any[]): void; }
