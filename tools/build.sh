#!/bin/zsh
# Build for the simulator. Pass --no-assets inside a sandbox where actool cannot run.
set -o pipefail
cd "$(dirname "$0")/.."
extra=()
[[ "$1" == "--no-assets" ]] && extra=('EXCLUDED_SOURCE_FILE_NAMES=Assets.xcassets')
xcodebuild -project Borro.xcodeproj -scheme Borro -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/BorroDD \
  CODE_SIGNING_ALLOWED=NO "${extra[@]}" build > /tmp/borro-build.log 2>&1
code=$?
grep -E "(error|warning):" /tmp/borro-build.log | grep -v "appintentsmetadataprocessor" | sed "s|$PWD/||" | sort -u
grep -E "\*\* BUILD" /tmp/borro-build.log
exit $code
