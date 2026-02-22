#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

EXCLUDE_DIRS=(".git" "build" "android" "ios" "macos" "windows" "linux" ".dart_tool" "coverage")

GREP_EXCLUDES=()
for d in "${EXCLUDE_DIRS[@]}"; do
  GREP_EXCLUDES+=(--exclude-dir="$d")
done

echo "Checking repository for deprecated color APIs..."

FOUND=0

# Patterns to detect
PATTERNS=("\.withOpacity\(" "\bColors\.")

for p in "${PATTERNS[@]}"; do
  # Use grep to search source files (case-sensitive)
  if matches=$(grep -RIn "${GREP_EXCLUDES[@]}" -e "$p" -- "lib" "test" || true); then
    if [ -n "$matches" ]; then
      echo "\nForbidden pattern '$p' found:" >&2
      echo "$matches" >&2
      FOUND=1
    fi
  fi
done

if [ $FOUND -ne 0 ]; then
  echo "\nERROR: Found deprecated color usages.\nReplace 'Color.withOpacity' with 'Color.withValues(alpha:)' and avoid direct 'Colors.*' in favor of Theme/AppColors." >&2
  exit 2
fi

echo "No deprecated color usages found."
