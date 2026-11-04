#!/bin/bash
# Build, install and screenshot the app on a booted simulator.
#   tools/shots.sh                # 4 tabs + design gallery
#   tools/shots.sh explore        # just one
set -euo pipefail
cd "$(dirname "$0")/.."

SIM=${SIM:-iPhone 17 Pro}
BID=com.borro.prototype
APP=".build/DerivedData/Build/Products/Debug-iphonesimulator/Borro.app"
OUT=docs/screens
mkdir -p "$OUT"

xcrun simctl boot "$SIM" 2>/dev/null || true
open -a Simulator 2>/dev/null || true

xcodebuild -project Borro.xcodeproj -scheme Borro -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=$SIM" -configuration Debug \
  -derivedDataPath .build/DerivedData build CODE_SIGNING_ALLOWED=NO \
  'EXCLUDED_SOURCE_FILE_NAMES=Assets.xcassets' >/tmp/borro-build.log 2>&1 || {
    grep -E 'error:' /tmp/borro-build.log | head -20; exit 1;
  }

xcrun simctl install booted "$APP"

shot() { # name, extra args
  local name="$1"; shift
  xcrun simctl terminate booted "$BID" 2>/dev/null || true
  sleep 0.5
  xcrun simctl launch booted "$BID" "$@" >/dev/null
  sleep 2.2
  xcrun simctl io booted screenshot "$OUT/$name.png" >/dev/null 2>&1
  echo "  ✓ $OUT/$name.png"
}

want=${1:-all}
if [ "$want" = "all" ] || [ "$want" = "explore" ];  then shot 01-explore  -uiTab explore;  fi
if [ "$want" = "all" ] || [ "$want" = "bookings" ]; then shot 02-bookings -uiTab bookings; fi
if [ "$want" = "all" ] || [ "$want" = "messages" ]; then shot 03-messages -uiTab messages; fi
if [ "$want" = "all" ] || [ "$want" = "profile" ];  then shot 04-profile  -uiTab profile;  fi
if [ "$want" = "all" ] || [ "$want" = "gallery" ];  then shot 05-gallery  -uiGallery;      fi
if [ "$want" = "all" ]; then shot 01-explore -uiTab explore; fi  # leave app on home
echo "Done."
