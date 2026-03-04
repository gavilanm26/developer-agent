#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  render-template-commons.sh --target <microservice-root> --service-name <name> [--components <csv>]

Description:
  Copies selected files/folders from .agent/templates/template-commons into <target>/src/commons,
  renders .tpl files (currently replaces {{SERVICE_NAME}}), and removes the .tpl suffix.

Components (csv, optional):
  constants,enums,headers,http-logger,https-agent,interceptor,libs,crypto,otel,token,basic-data,health-check

Defaults:
  If --components is omitted, copies all supported components.

Example:
  .agent/tools/scripts/render-template-commons.sh \
    --target ./credits-proof \
    --service-name credits-proof \
    --components http-logger,otel
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TEMPLATE_ROOT="$ROOT_DIR/.agent/templates/template-commons"

TARGET_DIR=""
SERVICE_NAME=""
COMPONENTS_CSV="constants,enums,headers,http-logger,https-agent,interceptor,libs,otel,token,basic-data,health-check"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET_DIR="${2:-}"
      shift 2
      ;;
    --service-name)
      SERVICE_NAME="${2:-}"
      shift 2
      ;;
    --components)
      COMPONENTS_CSV="${2:-}"
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

if [[ -z "$TARGET_DIR" || -z "$SERVICE_NAME" ]]; then
  echo "Both --target and --service-name are required." >&2
  usage >&2
  exit 1
fi

if [[ ! -d "$TEMPLATE_ROOT" ]]; then
  echo "Template root not found: $TEMPLATE_ROOT" >&2
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
DEST_COMMONS="$TARGET_DIR/src/commons"

mkdir -p "$DEST_COMMONS"

copy_component() {
  local component="$1"
  case "$component" in
    http-logger)
      mkdir -p "$DEST_COMMONS/http-logger"
      cp -R "$TEMPLATE_ROOT/http-logger/." "$DEST_COMMONS/http-logger/"
      ;;
    otel)
      cp "$TEMPLATE_ROOT/otel.config.ts.tpl" "$DEST_COMMONS/otel.config.ts.tpl"
      ;;
    interceptor)
      mkdir -p "$DEST_COMMONS/interceptor"
      cp -R "$TEMPLATE_ROOT/interceptor/." "$DEST_COMMONS/interceptor/"
      ;;
    constants)
      mkdir -p "$DEST_COMMONS/constants"
      cp -R "$TEMPLATE_ROOT/constants/." "$DEST_COMMONS/constants/"
      ;;
    enums)
      mkdir -p "$DEST_COMMONS/enums"
      cp -R "$TEMPLATE_ROOT/enums/." "$DEST_COMMONS/enums/"
      ;;
    headers)
      mkdir -p "$DEST_COMMONS/headers"
      cp -R "$TEMPLATE_ROOT/headers/." "$DEST_COMMONS/headers/"
      ;;
    https-agent)
      mkdir -p "$DEST_COMMONS/https-agent"
      cp -R "$TEMPLATE_ROOT/https-agent/." "$DEST_COMMONS/https-agent/"
      ;;
    libs)
      mkdir -p "$DEST_COMMONS/libs"
      cp -R "$TEMPLATE_ROOT/libs/." "$DEST_COMMONS/libs/"
      rm -rf "$DEST_COMMONS/libs/crypto"
      ;;
    crypto)
      mkdir -p "$DEST_COMMONS/libs/crypto"
      cp -R "$TEMPLATE_ROOT/libs/crypto/." "$DEST_COMMONS/libs/crypto/"
      ;;
    token)
      mkdir -p "$DEST_COMMONS/token"
      cp -R "$TEMPLATE_ROOT/token/." "$DEST_COMMONS/token/"
      ;;
    basic-data)
      mkdir -p "$DEST_COMMONS/basic-data"
      cp -R "$TEMPLATE_ROOT/basic-data/." "$DEST_COMMONS/basic-data/"
      ;;
    health-check)
      mkdir -p "$DEST_COMMONS/health-check"
      cp -R "$TEMPLATE_ROOT/health-check/." "$DEST_COMMONS/health-check/"
      ;;
    "")
      ;;
    *)
      echo "Unsupported component: $component" >&2
      exit 1
      ;;
  esac
}

IFS=',' read -r -a components <<< "$COMPONENTS_CSV"
for component in "${components[@]}"; do
  copy_component "$component"
done

while IFS= read -r tpl_file; do
  out_file="${tpl_file%.tpl}"
  sed \
    -e "s/{{SERVICE_NAME}}/${SERVICE_NAME}/g" \
    "$tpl_file" > "$out_file"
  rm -f "$tpl_file"
done < <(find "$DEST_COMMONS" -type f -name '*.tpl' | sort)

echo "Rendered commons templates into: $DEST_COMMONS"
echo "Components: $COMPONENTS_CSV"
