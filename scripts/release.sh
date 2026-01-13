#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="ImmichSync"
DIST_DIR="$ROOT_DIR/dist"

echo "ImmichSync release helper"
read -r "VERSION?Version (e.g. 1.0.1): "
if [[ -z "${VERSION}" ]]; then
  echo "Version is required."
  exit 1
fi

read -r "UPLOAD?Create GitHub release and upload assets? (y/N): "
UPLOAD="${UPLOAD:-N}"

cd "$ROOT_DIR"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree has changes."
  git status -sb
  read -r "COMMIT_MSG?Commit summary (e.g. Fix sync cache): "
  if [[ -z "${COMMIT_MSG}" ]]; then
    echo "Commit summary is required."
    exit 1
  fi
  git add -A
  git commit -m "$COMMIT_MSG"
  git push
else
  echo "Working tree clean. Skipping commit/push."
fi

./scripts/build-app.sh

DMG_PATH="$DIST_DIR/${APP_NAME}.dmg"
ZIP_PATH="$DIST_DIR/${APP_NAME}.zip"

if [[ ! -f "$DMG_PATH" || ! -f "$ZIP_PATH" ]]; then
  echo "Missing release artifacts in $DIST_DIR"
  exit 1
fi

NOTES=$'# ImmichSync '"${VERSION}"$' — Universal macOS Build\n\n## Highlights\n- Server duplicate checks are now cached persistently with a UI reset button\n- Download skip logic now rechecks disk so empty/new folders no longer skip assets\n\n## Download\nGet `ImmichSync.dmg` or `ImmichSync.zip` from the release assets down below.  \nYou can find detailed install instructions and troubleshooting regarding installations in the repos ReadMe File: https://github.com/bjoernch/Immichsync?tab=readme-ov-file#install-unsigned-build'

if [[ "${UPLOAD:l}" == "y" ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI (gh) not found. Install with: brew install gh"
    exit 1
  fi

  TAG="v${VERSION}"
  gh release create "$TAG" "$DMG_PATH" "$ZIP_PATH" \
    --title "$TAG" \
    --notes "$NOTES"
  echo "Release created: $TAG"
else
  echo "Build complete. Artifacts:"
  echo "  $DMG_PATH"
  echo "  $ZIP_PATH"
  echo ""
  echo "Release notes:"
  echo "$NOTES"
fi
