#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-}"

if [[ -z "${TARGET_DIR}" ]]; then
  echo "Usage: $0 <microservice-directory>"
  exit 2
fi

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "ERROR: Directory not found: ${TARGET_DIR}"
  exit 2
fi

cd "${TARGET_DIR}"

if [[ ! -f "package.json" ]]; then
  echo "ERROR: ${TARGET_DIR} is not a microservice root (missing package.json)"
  exit 2
fi

missing=0

check_pair() {
  local impl="$1"
  local spec="$2"
  if [[ -f "${impl}" && ! -f "${spec}" ]]; then
    echo "MISSING SPEC: ${impl} -> ${spec}"
    missing=1
  fi
}

while IFS= read -r impl; do
  spec="${impl%.ts}.spec.ts"
  check_pair "${impl}" "${spec}"
done < <(find src -type f -path "*/outbound/clients/*.rest.client.ts" | sort)

while IFS= read -r impl; do
  spec="${impl%.ts}.spec.ts"
  check_pair "${impl}" "${spec}"
done < <(find src -type f -path "*/outbound/repositories/*.repository.impl.ts" | sort)

while IFS= read -r impl; do
  spec="${impl%.ts}.spec.ts"
  check_pair "${impl}" "${spec}"
done < <(find src -type f -path "*/outbound/cache/*.cache.impl.ts" | sort)

while IFS= read -r impl; do
  spec="${impl%.ts}.spec.ts"
  check_pair "${impl}" "${spec}"
done < <(find src -type f -path "*/outbound/mappers/*.mapper.ts" | sort)

if [[ ${missing} -ne 0 ]]; then
  echo "FAIL: outbound test pairing validation failed."
  exit 1
fi

echo "OK: outbound test pairing validation passed."
