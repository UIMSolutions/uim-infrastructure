#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"
SEED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/seed" && pwd)"

post_json() {
  local path="$1"
  local body="$2"
  curl -fsS -X POST "$BASE_URL$path" \
    -H "Content-Type: application/json" \
    -d "$body"
}

json_escape_file() {
  sed ':a;N;$!ba;s/\\/\\\\/g;s/"/\\"/g;s/\n/\\n/g' "$1"
}

echo "[1/8] Health check"
curl -fsS "$BASE_URL/health" >/dev/null
echo "ok"

echo "[2/8] Ingest SAM dataset"
SAM_CONTENT="$(json_escape_file "$SEED_DIR/example.sam")"
post_json "/v1/hts/datasets" "{\"datasetId\":\"smoke-sam\",\"format\":\"sam\",\"rawContent\":\"$SAM_CONTENT\"}" >/dev/null

echo "[3/8] Ingest VCF dataset"
VCF_CONTENT="$(json_escape_file "$SEED_DIR/example.vcf")"
post_json "/v1/hts/datasets" "{\"datasetId\":\"smoke-vcf\",\"format\":\"vcf\",\"rawContent\":\"$VCF_CONTENT\"}" >/dev/null

echo "[4/8] Ingest FASTQ dataset"
FASTQ_CONTENT="$(json_escape_file "$SEED_DIR/example.fastq")"
post_json "/v1/hts/datasets" "{\"datasetId\":\"smoke-fastq\",\"format\":\"fastq\",\"rawContent\":\"$FASTQ_CONTENT\"}" >/dev/null

echo "[5/8] List datasets"
DATASETS_JSON="$(curl -fsS "$BASE_URL/v1/hts/datasets")"
echo "$DATASETS_JSON"

echo "[6/8] Query SAM records by reference chr1"
SAM_QUERY="$(curl -fsS "$BASE_URL/v1/hts/query/reference?datasetId=smoke-sam&reference=chr1")"
echo "$SAM_QUERY"

echo "[7/8] Generate UNIX hash"
HASH_JSON="$(post_json "/v1/unix/hash" "{\"password\":\"smoke-secret\",\"algorithm\":\"sha512\"}")"
echo "$HASH_JSON"

echo "[8/8] Verify UNIX hash"
HASH_VALUE="$(printf '%s' "$HASH_JSON" | sed -n 's/.*"hash":"\([^"]*\)".*/\1/p')"
if [[ -z "$HASH_VALUE" ]]; then
  echo "could not parse hash field from response"
  exit 1
fi
VERIFY_JSON="$(post_json "/v1/unix/verify" "{\"password\":\"smoke-secret\",\"existingHash\":\"$HASH_VALUE\"}")"
echo "$VERIFY_JSON"

echo "Smoke test completed successfully."
