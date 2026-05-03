declare module "express" {
  interface Response {
    write: (...args: any[]) => void;
    flushHeaders: () => void;
    setHeader: (...args: any[]) => void;
    on: (...args: any[]) => void;
  }
  interface Request {
    on: (...args: any[]) => void;
  }
}
