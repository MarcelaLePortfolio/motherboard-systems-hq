
import { db } from "./index";

declare global {

  var db: typeof db;

  var sqlite: typeof db;

}

globalThis.db = db;

globalThis.sqlite = db;

export {};

