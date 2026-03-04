#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  render-env-from-template.sh --target <microservice-root> --capabilities <csv> [--output <.env|.env.example>] [--template <path>]

Description:
  Generates a filtered env file from `.agent/templates/global/.env.tpl`, keeping
  original template values and only the variables required by detected capabilities.

Capabilities (csv):
  mongo,redis,external-api,auth,auth-recaptcha,https-agent,token,basic-data,crypto,otel,health-check

Examples:
  .agent/tools/scripts/render-env-from-template.sh \
    --target ./credits-proof \
    --capabilities mongo,redis

  .agent/tools/scripts/render-env-from-template.sh \
    --target ./auth-proof \
    --capabilities auth,auth-recaptcha,token,redis,https-agent \
    --output .env.example
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TEMPLATE_FILE="$ROOT_DIR/.agent/templates/global/.env.tpl"
TARGET_DIR=""
OUTPUT_NAME=".env"
CAPABILITIES_CSV=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET_DIR="${2:-}"
      shift 2
      ;;
    --capabilities)
      CAPABILITIES_CSV="${2:-}"
      shift 2
      ;;
    --output)
      OUTPUT_NAME="${2:-}"
      shift 2
      ;;
    --template)
      TEMPLATE_FILE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$TARGET_DIR" || -z "$CAPABILITIES_CSV" ]]; then
  echo "Both --target and --capabilities are required." >&2
  usage >&2
  exit 1
fi

if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "Template file not found: $TEMPLATE_FILE" >&2
  exit 1
fi

if [[ "$OUTPUT_NAME" != ".env" && "$OUTPUT_NAME" != ".env.example" ]]; then
  echo "--output must be either .env or .env.example" >&2
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
OUTPUT_FILE="$TARGET_DIR/$OUTPUT_NAME"

declare -A REQUIRED_KEYS=()
declare -A FOUND_KEYS=()
add_key() {
  local key="$1"
  [[ -n "$key" ]] && REQUIRED_KEYS["$key"]=1
}

# Baseline
add_key "PORT"

IFS=',' read -r -a CAPS <<< "$CAPABILITIES_CSV"
for raw_cap in "${CAPS[@]}"; do
  cap="$(echo "$raw_cap" | xargs)"
  case "$cap" in
    mongo)
      add_key "APPMONGOSTRING"
      ;;
    redis)
      add_key "INFRAREDISHOST"
      add_key "INFRAREDISPORT"
      add_key "INFRAREDISPASS"
      add_key "INFRAREDISTTL"
      ;;
    external-api)
      add_key "APICOREURL"
      ;;
    auth)
      add_key "APIAUTHURL"
      add_key "APIAUTHCLIENTID"
      add_key "APIAUTHCLIENTSECRET"
      add_key "INFRAENCRYPTKEYCORE"
      ;;
    auth-recaptcha|recaptcha|re-captcha)
      add_key "INFRAGOOGLERECAPTCHAURL"
      add_key "INFRARECAPTCHASECRETKEY"
      ;;
    https-agent|tls)
      add_key "CERTIFICATE"
      add_key "CERTIFICATECA"
      add_key "CERTIFICATEKEY"
      ;;
    token)
      add_key "APIURLCOMMONSIDENTITYMANAGEMENT"
      ;;
    basic-data)
      add_key "APIURLCOMMONSBASICDATA"
      ;;
    crypto)
      add_key "INFRAENCRYPTKEYCORE"
      ;;
    otel|health-check|"")
      ;;
    *)
      echo "Warning: unknown capability '$cap' (ignored)" >&2
      ;;
  esac
done

tmp="$(mktemp)"
pending_comments=""
printed=0

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "${line//[[:space:]]/}" ]] || [[ "$line" =~ ^\[[^]]+\]$ ]]; then
    if [[ -z "$pending_comments" ]]; then
      pending_comments="$line"
    else
      pending_comments+=$'\n'"$line"
    fi
    continue
  fi

  if [[ "$line" =~ ^([A-Z0-9_]+)= ]]; then
    key="${BASH_REMATCH[1]}"
    if [[ -n "${REQUIRED_KEYS[$key]:-}" ]]; then
      if [[ -n "$pending_comments" ]]; then
        if [[ $printed -eq 1 ]]; then
          echo "" >> "$tmp"
        fi
        printf '%s\n' "$pending_comments" >> "$tmp"
      fi

      printf '%s\n' "$line" >> "$tmp"
      FOUND_KEYS["$key"]=1
      printed=1
    fi
    pending_comments=""
    continue
  fi

  pending_comments=""
done < "$TEMPLATE_FILE"

mv "$tmp" "$OUTPUT_FILE"

for key in "${!REQUIRED_KEYS[@]}"; do
  if [[ -z "${FOUND_KEYS[$key]:-}" ]]; then
    echo "Warning: required key '$key' not found in template $TEMPLATE_FILE" >&2
  fi
done

echo "Generated filtered env file: $OUTPUT_FILE"
echo "Capabilities: $CAPABILITIES_CSV"
