
import db from "./index";

declare global {

  var db: any;

  var sqlite: any;

}

globalThis.db = db as any;

globalThis.sqlite = db as any;

export {};

