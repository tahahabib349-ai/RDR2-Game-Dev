#!/usr/bin/env bash
set -euo pipefail
web_repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$web_repo/game/tools/env.sh"
[[ "$("$GODOT_BIN" --version)" == "$(cat "$web_repo/game/GODOT_VERSION")" ]] || { echo 'Godot version mismatch' >&2; exit 1; }
python3 "$web_repo/game/tools/setup_web.py"
mkdir -p "$web_repo/game/export/web"
"$GODOT_BIN" --headless --path "$web_repo/game" --import
"$GODOT_BIN" --headless --path "$web_repo/game" --export-release Web "$web_repo/game/export/web/index.html"
test -s "$web_repo/game/export/web/index.wasm"
test -s "$web_repo/game/export/web/index.pck"
touch "$web_repo/game/export/web/.nojekyll"
echo "Web build: $web_repo/game/export/web/index.html"
