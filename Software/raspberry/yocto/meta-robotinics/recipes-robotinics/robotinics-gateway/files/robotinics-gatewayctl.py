#!/usr/bin/env python3
import argparse
import json
import os
import urllib.request

BASE = os.getenv("ROBOTINICS_GATEWAY_URL", "http://127.0.0.1:8765")


def get(path):
    with urllib.request.urlopen(BASE + path, timeout=10) as r:
        return json.loads(r.read().decode("utf-8"))


def post(path, payload):
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(BASE + path, data=data,
                                 headers={"Content-Type": "application/json"},
                                 method="POST")
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode("utf-8"))


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="op", required=True)
    sub.add_parser("state")
    sub.add_parser("catalog")
    h = sub.add_parser("history")
    h.add_argument("--limit", type=int, default=20)
    c = sub.add_parser("command")
    c.add_argument("command")
    c.add_argument("--timeout", type=float, default=5)
    args = p.parse_args()

    if args.op == "state":
        out = get("/v1/state")
    elif args.op == "catalog":
        out = get("/v1/catalog")
    elif args.op == "history":
        out = get("/v1/history?limit=%d" % args.limit)
    else:
        out = post("/v1/command", {"command": args.command, "timeout": args.timeout})

    print(json.dumps(out, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
