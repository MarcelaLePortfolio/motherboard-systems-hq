
declare module "express" {

  import { RequestHandler } from "express-serve-static-core";

  export interface Request {

    body?: any;

  }

  export interface Response {

    json: any;

    status: any;

  }

  export interface Router {

    get: any;

    post: any;

    use: any;

  }

  const express: any;

  export default express;

  export function Router(): any;

}

