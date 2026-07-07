
import { db, sqlite } from "./index";

declare global {

  var db: any;

  var sqlite: any;

}

globalThis.db = db;

globalThis.sqlite = sqlite;

export {};

