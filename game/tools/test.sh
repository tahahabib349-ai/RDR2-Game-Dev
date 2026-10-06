#!/usr/bin/env bash
set -euo pipefail
_rts_game_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$_rts_game_dir/tools/env.sh"
[[ "$("$GODOT_BIN" --headless --version)" == "$(cat "$_rts_game_dir/GODOT_VERSION")" ]] || {
    echo "Wrong Godot version. Run game/tools/setup.sh." >&2
    exit 1
}
_rts_log="$(mktemp)"
trap 'rm -f -- "$_rts_log"' EXIT
_rts_status=0
timeout 60 "$GODOT_BIN" --headless --path "$_rts_game_dir" --script res://tests/test_runner.gd -- "$@" >"$_rts_log" 2>&1 || _rts_status=$?
cat "$_rts_log"
# Godot can exit 0 on script-load errors: reject these independently of runner status.
if [[ $_rts_status -ne 0 ]]; then
    exit "$_rts_status"
fi
if grep -Eq 'SCRIPT ERROR:|^ERROR:|^WARNING:.*leaked' "$_rts_log" || ! grep -Eq '^Results: [1-9][0-9]* passed, 0 failed$' "$_rts_log"; then
    exit 1
fi
