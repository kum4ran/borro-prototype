#!/bin/bash
# Materialise iCloud-evicted ("dataless") files in this workspace.
#
# Symptom: reading a file (cat, Xcode, python) hangs or fails with ETIMEDOUT /
# errno 60, while `stat -f %Sf file` shows "compressed,dataless".
# Cause: macOS iCloud Drive evicts file contents when the disk is tight.
# Fix: `cp -c` (APFS clone) forces the content local, then write it back.
#
#   tools/materialize.sh          # every dataless file
#   tools/materialize.sh Borro    # only under a subpath
set -uo pipefail
cd "$(dirname "$0")/.."
TARGET="${1:-.}"

list_dataless() {
  find "$TARGET" -type f ! -path './.build/*' ! -path './.git/*' ! -name '.DS_Store' 2>/dev/null |
  while IFS= read -r f; do
    case "$(stat -f '%Sf' "$f" 2>/dev/null || true)" in
      *dataless*) printf '%s\n' "$f" ;;
    esac
  done
}

repair_one() {
  tmp=$(mktemp /tmp/borro-materialise.XXXXXX) || return 0
  if cp -c "$1" "$tmp" 2>/dev/null; then
    cp "$tmp" "$1" 2>/dev/null || true
  fi
  rm -f "$tmp"
}

COUNT=$(list_dataless | wc -l | tr -d ' ')
echo "dataless files: $COUNT"
[ "$COUNT" -eq 0 ] && { echo "nothing to do"; exit 0; }

export -f repair_one
list_dataless | xargs -P 8 -I{} bash -c 'repair_one "$@"' _ "{}"

LEFT=$(list_dataless | wc -l | tr -d ' ')
echo "remaining dataless: $LEFT"
[ "$LEFT" -gt 0 ] && echo "Free disk space (several GB) and re-run, or move the project out of iCloud Drive."
exit 0
