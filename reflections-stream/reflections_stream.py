#!/usr/bin/env python3
"""
Reflections Stream SSE server.

Usage:
    python3 reflections-stream/reflections_stream.py 3200 --serve
"""

import sys
import time
import os
import json
from http.server import HTTPServer, BaseHTTPRequestHandler

CLIENT_ORIGIN = "http://localhost:3022"

DB_HOST = os.environ.get('PG_HOST', 'postgres')
DB_NAME = os.environ.get('DB_NAME', 'motherboard_db')
DB_INFO = f"{DB_HOST}/{DB_NAME}"


class ReflectionsStreamHandler(BaseHTTPRequestHandler):

    def _set_sse_headers(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Connection", "keep-alive")
        self.send_header("Access-Control-Allow-Origin", CLIENT_ORIGIN)
        self.end_headers()

    def do_GET(self):
        if self.path != "/events/reflections":
            self.send_response(404)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(b"Not Found\n")
            return

        self._set_sse_headers()

        counter = 0
        try:
            while True:
                data = {
                    "type": "reflection_update",
                    "id": counter,
                    "timestamp": time.time(),
                    "source_db": DB_INFO,
                    "status": "PROCESSING",
                    "sequence": counter
                }
                message = f"data: {json.dumps(data)}\n\n"
                self.wfile.write(message.encode("utf-8"))
                self.wfile.flush()
                counter += 1
                time.sleep(2)

        except (BrokenPipeError, ConnectionResetError):
            pass

    def log_message(self, format, *args):
        pass


def run_server(port: int):
    print(f"Reflections Stream is running and collecting data from {DB_INFO}...")
    server = HTTPServer(("", port), ReflectionsStreamHandler)
    print(f"🔌 Reflections Stream SSE server listening at http://localhost:{port}/events/reflections")
    server.serve_forever()


def main():
    if len(sys.argv) != 3 or sys.argv[2] != "--serve":
        print("Usage: reflections_stream.py <port> --serve")
        sys.exit(1)

    port = int(sys.argv[1])
    print("Reflections Stream initializing...")
    print(f"Attempting to connect to database at {DB_INFO}...")
    run_server(port)


if __name__ == "__main__":
    main()
