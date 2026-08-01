#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "[acdoca] starting service + postgres with docker compose..."
docker compose up --build
