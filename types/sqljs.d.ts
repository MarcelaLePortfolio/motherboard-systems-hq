declare module "sql.js" {
  export interface QueryExecResult {
    columns: string[];
    values: any[][];
  }

  export interface Database {
    exec(sql: string): QueryExecResult[];
    close(): void;
  }

  export interface SqlJsStatic {
    Database: new (data?: Uint8Array) => Database;
  }

  export default function initSqlJs(config?: {
    locateFile?: (file: string) => string;
  }): Promise<SqlJsStatic>;
}
