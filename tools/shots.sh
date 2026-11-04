#!/bin/zsh
# Screenshot frames in the simulator and pair each with its Figma render.
#   tools/shots.sh 1.1 1.2 2.4      selected frames
#   tools/shots.sh all              every frame
#   DEVICE="Borro-SE" OUT=Docs/screens/se tools/shots.sh 2.1   another device, no side-by-side
# Output: Docs/screens/app/<code>.png and Docs/screens/compare/<code>.png (Figma left, app right).
cd "$(dirname "$0")/.."
DEVICE=${DEVICE:-"iPhone 17 Pro"}
APP=/tmp/BorroDD/Build/Products/Debug-iphonesimulator/Borro.app
xcrun simctl boot "$DEVICE" 2>/dev/null
xcrun simctl bootstatus "$DEVICE" -b >/dev/null
xcrun simctl install "$DEVICE" "$APP"
codes=("$@")
[[ "$1" == "all" ]] && codes=($(python3 -c "import json;print(' '.join(s['code'] for s in json.load(open('Docs/figma-links.json'))['screens']))"))
OUT=${OUT:-Docs/screens/app}
mkdir -p "$OUT" Docs/screens/compare
for c in $codes; do
  xcrun simctl terminate "$DEVICE" com.tjandera.borro 2>/dev/null
  xcrun simctl launch "$DEVICE" com.tjandera.borro -startScreen "$c" >/dev/null
  sleep ${WAIT:-2.5}
  xcrun simctl io "$DEVICE" screenshot "$OUT/$c.png" >/dev/null 2>&1
done
[[ "$OUT" == Docs/screens/app ]] && python3 tools/compare.py $codes
