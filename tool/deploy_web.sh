#!/usr/bin/env bash
# Builds the Flutter web app and publishes `build/web` to the static deploy
# repo that Vercel serves (same setup as Zood-E-Invoice-flutter).
#
# Usage: tool/deploy_web.sh ["commit message"]
# Override the deploy checkout with DEPLOY_DIR=/path/to/repo.
# Uses the AppConfig defaults (dev API); set API_BASE_URL for production,
# or USE_DUMMY_DATA=true for the offline demo.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEPLOY_DIR="${DEPLOY_DIR:-$PROJECT_DIR/../Zood-Pay-at-table-web}"
MESSAGE="${1:-Deploy web build $(date '+%Y-%m-%d %H:%M')}"

DEFINES=()
[ -n "${API_BASE_URL:-}" ] && DEFINES+=(--dart-define=API_BASE_URL="$API_BASE_URL")
[ -n "${USE_DUMMY_DATA:-}" ] && DEFINES+=(--dart-define=USE_DUMMY_DATA="$USE_DUMMY_DATA")

cd "$PROJECT_DIR"
flutter build web --release ${DEFINES[@]+"${DEFINES[@]}"}

mkdir -p "$DEPLOY_DIR"
if [ ! -d "$DEPLOY_DIR/.git" ]; then
  git -C "$DEPLOY_DIR" init -b main
fi

rsync -a --delete --exclude '.git' --exclude 'README.md' build/web/ "$DEPLOY_DIR/"

cd "$DEPLOY_DIR"
git add -A
if git diff --cached --quiet; then
  echo "Nothing changed since the last deploy."
  exit 0
fi
git commit -m "$MESSAGE"

if git remote get-url origin >/dev/null 2>&1; then
  git push origin main
else
  echo "No 'origin' remote yet. Add it with:"
  echo "  git -C \"$DEPLOY_DIR\" remote add origin <repo-url> && git -C \"$DEPLOY_DIR\" push -u origin main"
fi
