#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ "${1:-}" == "--purge" ]]; then
  echo "[acdoca] stopping stack and removing volumes..."
  docker compose down -v
else
  echo "[acdoca] stopping stack..."
  docker compose down
fi
