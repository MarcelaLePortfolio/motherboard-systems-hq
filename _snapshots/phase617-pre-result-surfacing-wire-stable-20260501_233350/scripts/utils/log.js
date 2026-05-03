"use strict";
exports.__esModule = true;
exports.log = void 0;
/**
 * Minimal logging utility for agents
 */
function log() {
    var args = [];
    for (var _i = 0; _i < arguments.length; _i++) {
        args[_i] = arguments[_i];
    }
    console.log.apply(console, args);
}
exports.log = log;
