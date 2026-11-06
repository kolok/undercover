#!/usr/bin/env sh
# Active les hooks versionnés (ex. pre-commit : dart format).
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
git config core.hooksPath .githooks
echo "Git : core.hooksPath est réglé sur .githooks (depuis $(pwd))"
