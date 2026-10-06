#!/usr/bin/env bash
set -euo pipefail
_rts_game_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
_rts_android_workspace="$(dirname -- "$(dirname -- "$_rts_game_dir")")"
source "$_rts_game_dir/tools/env.sh"
[[ "$("$GODOT_BIN" --headless --version)" == "$(cat "$_rts_game_dir/GODOT_VERSION")" ]] || {
    echo "Wrong Godot version. Run game/tools/setup.sh first." >&2
    exit 1
}
export ANDROID_SDK_ROOT="$_rts_android_workspace/.tools/android-sdk"
export ANDROID_USER_HOME="$_rts_android_workspace/.runtime/android"
export JAVA_HOME="${JAVA_HOME:-$(dirname -- "$(dirname -- "$(readlink -f -- "$(command -v java)")")")}"
python3 "$_rts_game_dir/tools/setup_android.py"
mkdir -p "$_rts_game_dir/export"
_rts_apk="$_rts_game_dir/export/breakpoint-valley-phase1-debug.apk"
"$GODOT_BIN" --headless --path "$_rts_game_dir" --export-debug "Android Debug" "$_rts_apk"
"$ANDROID_SDK_ROOT/build-tools/36.0.0/apksigner" verify --verbose "$_rts_apk"
"$ANDROID_SDK_ROOT/build-tools/36.0.0/zipalign" -c -P 16 4 "$_rts_apk"
sha256sum "$_rts_apk"
