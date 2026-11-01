#!/usr/bin/env bash
# Builds a universal, ad-hoc signed ExternalMacAwake.app into build/.
#   scripts/bundle.sh          build the .app
#   scripts/bundle.sh --zip    also write build/ExternalMacAwake-<version>.zip
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

make_zip=0
for arg in "$@"; do
  case "$arg" in
    --zip) make_zip=1 ;;
    -h | --help)
      sed -n '2,4p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "unknown argument: $arg" >&2
      exit 64
      ;;
  esac
done

version="$(tr -d '[:space:]' <VERSION)"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
  echo "VERSION must look like 1.2.3, got: '$version'" >&2
  exit 65
fi

app="build/ExternalMacAwake.app"

echo "==> Building universal release binary"
swift build -c release --arch arm64 --arch x86_64
bin_dir="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)"

echo "==> Assembling $app ($version)"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$bin_dir/ExternalMacAwake" "$app/Contents/MacOS/ExternalMacAwake"
sed "s/@VERSION@/$version/g" Resources/Info.plist >"$app/Contents/Info.plist"
printf 'APPL????' >"$app/Contents/PkgInfo"
plutil -lint "$app/Contents/Info.plist"

echo "==> Signing (ad hoc)"
codesign --force --deep --sign - "$app"
codesign --verify --deep --strict --verbose=2 "$app"

echo "==> Architectures: $(lipo -archs "$app/Contents/MacOS/ExternalMacAwake")"

if [[ "$make_zip" -eq 1 ]]; then
  zip="build/ExternalMacAwake-$version.zip"
  rm -f "$zip"
  ditto -c -k --keepParent "$app" "$zip"
  echo "==> Wrote $zip"
fi

echo "==> Done: $app"
