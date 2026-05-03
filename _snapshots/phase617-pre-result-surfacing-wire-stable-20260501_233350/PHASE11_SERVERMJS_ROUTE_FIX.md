# Phase 11 – server.mjs Catch-All Route Fix

## Problem

Running:

node server.mjs

produced:

PathError [TypeError]: Missing parameter name at index 1: *  
Express 5 (via path-to-regexp v8) no longer supports the bare "*" route:

app.get('*', handler)

## Fix

Replace:

app.get('*', ...)

with:

app.use(...)

which is Express-safe and serves as a valid catch-all route.

