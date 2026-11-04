#!/bin/bash
# QA screenshot harness for teammates.
#
#   tools/qc.sh <name> <slug> [<slug> ...]
#
# - creates/reuses a simulator named Borro-QA-<name>
# - builds with its own derived data
# - installs, launches each artboard via the app's -uiScreen deep link
# - writes docs/screens/qc/<slug>.png
set -uo pipefail
cd "$(dirname "$0")/.."

NAME=${1:?usage: tools/qc.sh <name> <slug> [slug...]}; shift
SLUGS=("$@")
[ ${#SLUGS[@]} -eq 0 ] && { echo "no slugs given"; exit 1; }

SIM_NAME="Borro-QA-$NAME"
DEVICE_TYPE="iPhone 17"
UDID=$(xcrun simctl list devices available | grep "$SIM_NAME (" | head -1 | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')
if [ -z "${UDID:-}" ]; then
  UDID=$(xcrun simctl create "$SIM_NAME" "$DEVICE_TYPE" 2>/dev/null)
fi
echo "simulator: $SIM_NAME ($UDID)"
xcrun simctl boot "$UDID" 2>/dev/null
sleep 2

DD=".build/DD-$NAME"
APP="$DD/Build/Products/Debug-iphonesimulator/Borro.app"

echo "building…"
xcodebuild -project Borro.xcodeproj -scheme Borro -sdk iphonesimulator \
  -destination "platform=iOS Simulator,id=$UDID" -configuration Debug \
  -derivedDataPath "$DD" build CODE_SIGNING_ALLOWED=NO \
  'EXCLUDED_SOURCE_FILE_NAMES=Assets.xcassets' > "/tmp/borro-build-$NAME.log" 2>&1
if [ $? -ne 0 ]; then
  echo "BUILD FAILED — errors:"
  grep -E 'error: ' "/tmp/borro-build-$NAME.log" | sed 's|.*/Borro/||' | sort -u | head -30
  exit 1
fi

xcrun simctl install "$UDID" "$APP" || exit 1
mkdir -p docs/screens/qc

for slug in "${SLUGS[@]}"; do
  xcrun simctl terminate "$UDID" com.borro.prototype 2>/dev/null
  sleep 0.3
  xcrun simctl launch "$UDID" com.borro.prototype -uiScreen "$slug" >/dev/null
  sleep 2.6
  xcrun simctl io "$UDID" screenshot "docs/screens/qc/$slug.png" >/dev/null 2>&1
  echo "  ✓ docs/screens/qc/$slug.png"
done
