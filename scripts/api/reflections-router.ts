// <0001fb29> reflections router (ESM-safe import normalization)
import express from "./express-shared";
import * as allModule from "./reflections-all";
import * as latestModule from "./reflections-latest";

const reflectionsAllHandler =
  allModule.reflectionsAllHandler || allModule.default;
const reflectionsLatestHandler =
  latestModule.reflectionsLatestHandler || latestModule.default;

const router = express.Router({ strict: false, caseSensitive: false });

router.get(["/", "/all"], reflectionsAllHandler);
router.get("/latest", reflectionsLatestHandler);

console.log("<0001fb29> reflectionsRouter initialized with verified callable handlers");

export default router;
