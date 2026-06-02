#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:9312}"
REPO="${REPO:-ci/smoke}"
TAG="${TAG:-ci-v1}"
MANIFEST_DIGEST="${MANIFEST_DIGEST:-sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa}"
BLOB_DIGEST="${BLOB_DIGEST:-sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb}"
JUNIT_FILE="${JUNIT_FILE:-./reports/keppel-smoke.xml}"

MANIFEST='{"schemaVersion":2,"mediaType":"application/vnd.oci.image.manifest.v1+json","config":{"mediaType":"application/vnd.oci.image.config.v1+json","digest":"sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc","size":2},"layers":[]}'
BLOB_PAYLOAD='hello-keppel-ci-blob'

TESTS=0
FAILURES=0
CASE_XML=""

xml_escape() {
  local s="$1"
  s="${s//&/&amp;}"
  s="${s//</&lt;}"
  s="${s//>/&gt;}"
  s="${s//\"/&quot;}"
  s="${s//\'/&apos;}"
  printf '%s' "$s"
}

record_pass() {
  local name="$1"
  TESTS=$((TESTS + 1))
  CASE_XML+="<testcase name=\"$(xml_escape "$name")\"/>"
}

record_fail() {
  local name="$1"
  local details="$2"
  TESTS=$((TESTS + 1))
  FAILURES=$((FAILURES + 1))
  CASE_XML+="<testcase name=\"$(xml_escape "$name")\"><failure message=\"request failed\">$(xml_escape "$details")</failure></testcase>"
}

run_case() {
  local name="$1"
  local method="$2"
  local url="$3"
  local expected="$4"
  local data="${5:-}"
  local content_type="${6:-application/json}"

  local tmp_body
  tmp_body="$(mktemp)"
  local code

  if [[ -n "$data" ]]; then
    code="$(curl -sS -X "$method" "$url" -H "Content-Type: $content_type" --data-binary "$data" -o "$tmp_body" -w "%{http_code}" || true)"
  else
    code="$(curl -sS -X "$method" "$url" -o "$tmp_body" -w "%{http_code}" || true)"
  fi

  if [[ "$code" == "$expected" ]]; then
    record_pass "$name"
  else
    local body
    body="$(cat "$tmp_body" 2>/dev/null || true)"
    record_fail "$name" "method=$method url=$url expected=$expected got=$code body=$body"
  fi

  rm -f "$tmp_body"
}

run_blob_roundtrip_case() {
  local name="$1"
  local url="$2"
  local expected="$3"
  local want="$4"

  local tmp_body
  tmp_body="$(mktemp)"
  local code

  code="$(curl -sS -X GET "$url" -o "$tmp_body" -w "%{http_code}" || true)"
  local got
  got="$(cat "$tmp_body" 2>/dev/null || true)"

  if [[ "$code" == "$expected" && "$got" == "$want" ]]; then
    record_pass "$name"
  else
    record_fail "$name" "url=$url expected_code=$expected got_code=$code expected_payload=$want got_payload=$got"
  fi

  rm -f "$tmp_body"
}

write_junit() {
  mkdir -p "$(dirname "$JUNIT_FILE")"
  cat > "$JUNIT_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="keppel-oci-smoke" tests="$TESTS" failures="$FAILURES">
$CASE_XML
</testsuite>
EOF
}

main() {
  run_case "health" GET "$BASE_URL/health" 200
  run_case "create repository" POST "$BASE_URL/v1/repositories" 201 "{\"name\":\"$REPO\",\"project_id\":\"smoke-ci\",\"visibility\":\"private\"}"

  run_case "put manifest" PUT "$BASE_URL/v2/$REPO/manifests/$TAG" 201 "$MANIFEST" "application/vnd.oci.image.manifest.v1+json"
  run_case "get manifest" GET "$BASE_URL/v2/$REPO/manifests/$TAG" 200

  run_case "put blob" PUT "$BASE_URL/v2/$REPO/blobs/$BLOB_DIGEST" 201 "$BLOB_PAYLOAD" "application/octet-stream"
  run_blob_roundtrip_case "get blob" "$BASE_URL/v2/$REPO/blobs/$BLOB_DIGEST" 200 "$BLOB_PAYLOAD"

  run_case "tags list" GET "$BASE_URL/v2/$REPO/tags/list" 200
  run_case "catalog" GET "$BASE_URL/v2/_catalog" 200
  run_case "v1 repository read" GET "$BASE_URL/v1/repositories/$REPO" 200

  write_junit

  echo "JUnit report written to: $JUNIT_FILE"
  if [[ "$FAILURES" -gt 0 ]]; then
    echo "Smoke test failed with $FAILURES failing case(s)."
    exit 1
  fi

  echo "Smoke test passed with $TESTS case(s)."
}

main "$@"
