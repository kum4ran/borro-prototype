#!/bin/bash
# Build once, then screenshot every Figma artboard through the app's deep links.
#   tools/qa_all.sh            # all 122 artboards
#   tools/qa_all.sh 703 691    # only slugs containing these substrings
set -uo pipefail
cd "$(dirname "$0")/.."

SIM_NAME="Borro-QA"
UDID=$(xcrun simctl list devices available | grep "$SIM_NAME (" | head -1 | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')
if [ -z "${UDID:-}" ]; then
  UDID=$(xcrun simctl create "$SIM_NAME" "iPhone 17 Pro" 2>/dev/null)
fi
echo "simulator: $UDID"
xcrun simctl boot "$UDID" 2>/dev/null
sleep 3

DD=/tmp/DD-qa
APP="$DD/Build/Products/Debug-iphonesimulator/Borro.app"
xcodebuild -project Borro.xcodeproj -scheme Borro -sdk iphonesimulator \
  -destination "platform=iOS Simulator,id=$UDID" -configuration Debug \
  -derivedDataPath "$DD" build CODE_SIGNING_ALLOWED=NO \
  'EXCLUDED_SOURCE_FILE_NAMES=Assets.xcassets' > /tmp/borro-qa-build.log 2>&1
if [ $? -ne 0 ]; then
  echo "BUILD FAILED:"
  grep -E 'error: ' /tmp/borro-qa-build.log | sed 's|.*/Borro/||' | sort -u | head -40
  exit 1
fi
xcrun simctl install "$UDID" "$APP" || exit 1

mkdir -p docs/screens/qa
SLUGS=$(python3 - <<'PY'
import json
idx=json.load(open('design/figma/frames/index.json'))
print(' '.join(f for s in idx['sections'] for f in s['frames']))
PY
)
for arg in "$@"; do :; done

count=0
for slug in $SLUGS; do
  if [ $# -gt 0 ]; then
    match=0
    for a in "$@"; do [[ "$slug" == *"$a"* ]] && match=1; done
    [ $match -eq 0 ] && continue
  fi
  xcrun simctl terminate "$UDID" com.borro.prototype 2>/dev/null
  sleep 0.25
  xcrun simctl launch "$UDID" com.borro.prototype -uiScreen "$slug" >/dev/null 2>&1
  sleep 2.3
  xcrun simctl io "$UDID" screenshot "docs/screens/qa/$slug.png" >/dev/null 2>&1
  count=$((count+1))
  echo "  [$count] $slug"
done
echo "captured $count screenshots -> docs/screens/qa/"
