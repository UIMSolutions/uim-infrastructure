#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:9312}"
REPO="${REPO:-demo/smoke}"
TAG="${TAG:-v1}"
MANIFEST_DIGEST="${MANIFEST_DIGEST:-sha256:1111111111111111111111111111111111111111111111111111111111111111}"
BLOB_DIGEST="${BLOB_DIGEST:-sha256:2222222222222222222222222222222222222222222222222222222222222222}"

MANIFEST='{"schemaVersion":2,"mediaType":"application/vnd.oci.image.manifest.v1+json","config":{"mediaType":"application/vnd.oci.image.config.v1+json","digest":"sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc","size":2},"layers":[]}'
BLOB_PAYLOAD='hello-keppel-blob'

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 1
  }
}

request_json() {
  local method="$1"
  local url="$2"
  local expected="$3"
  local data="${4:-}"
  local ctype="${5:-application/json}"

  local out
  local code

  if [[ -n "$data" ]]; then
    out="$(curl -sS -X "$method" "$url" -H "Content-Type: $ctype" --data-binary "$data" -o /tmp/keppel-smoke-body.$$ -w "%{http_code}")"
  else
    out="$(curl -sS -X "$method" "$url" -o /tmp/keppel-smoke-body.$$ -w "%{http_code}")"
  fi
  code="$out"

  if [[ "$code" != "$expected" ]]; then
    echo "request failed: $method $url expected=$expected got=$code" >&2
    cat /tmp/keppel-smoke-body.$$ >&2 || true
    rm -f /tmp/keppel-smoke-body.$$ || true
    exit 1
  fi

  cat /tmp/keppel-smoke-body.$$ || true
  rm -f /tmp/keppel-smoke-body.$$ || true
}

request_binary() {
  local method="$1"
  local url="$2"
  local expected="$3"
  local data="${4:-}"
  local ctype="${5:-application/octet-stream}"

  local code
  if [[ -n "$data" ]]; then
    code="$(curl -sS -X "$method" "$url" -H "Content-Type: $ctype" --data-binary "$data" -o /tmp/keppel-smoke-bin.$$ -w "%{http_code}")"
  else
    code="$(curl -sS -X "$method" "$url" -o /tmp/keppel-smoke-bin.$$ -w "%{http_code}")"
  fi

  if [[ "$code" != "$expected" ]]; then
    echo "request failed: $method $url expected=$expected got=$code" >&2
    rm -f /tmp/keppel-smoke-bin.$$ || true
    exit 1
  fi

  cat /tmp/keppel-smoke-bin.$$ || true
  rm -f /tmp/keppel-smoke-bin.$$ || true
}

main() {
  require_cmd curl

  echo "[1/9] health"
  request_json GET "$BASE_URL/health" 200 >/dev/null

  echo "[2/9] create repository"
  request_json POST "$BASE_URL/v1/repositories" 201 "{\"name\":\"$REPO\",\"project_id\":\"smoke\",\"visibility\":\"private\"}" >/dev/null

  echo "[3/9] put manifest"
  request_json PUT "$BASE_URL/v2/$REPO/manifests/$TAG" 201 "$MANIFEST" "application/vnd.oci.image.manifest.v1+json" >/dev/null

  echo "[4/9] get manifest"
  request_json GET "$BASE_URL/v2/$REPO/manifests/$TAG" 200 >/dev/null

  echo "[5/9] put blob"
  request_binary PUT "$BASE_URL/v2/$REPO/blobs/$BLOB_DIGEST" 201 "$BLOB_PAYLOAD" "application/octet-stream" >/dev/null

  echo "[6/9] get blob"
  local blob
  blob="$(request_binary GET "$BASE_URL/v2/$REPO/blobs/$BLOB_DIGEST" 200)"
  [[ "$blob" == "$BLOB_PAYLOAD" ]] || {
    echo "blob payload mismatch" >&2
    exit 1
  }

  echo "[7/9] list tags"
  request_json GET "$BASE_URL/v2/$REPO/tags/list" 200

  echo "[8/9] catalog"
  request_json GET "$BASE_URL/v2/_catalog" 200

  echo "[9/9] v1 repository read"
  request_json GET "$BASE_URL/v1/repositories/$REPO" 200

  echo "smoke test passed"
}

main "$@"
