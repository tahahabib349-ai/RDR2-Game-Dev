#!/usr/bin/env bash
set -euo pipefail
_rts_game_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$_rts_game_dir/tools/env.sh"
_rts_expected="$(cat "$_rts_game_dir/GODOT_VERSION")"
if ! command -v "$GODOT_BIN" >/dev/null || [[ "$("$GODOT_BIN" --headless --version)" != "$_rts_expected" ]]; then
    [[ "$(uname -s)" == Linux && "$(uname -m)" == x86_64 ]] || {
        echo "Install Godot $_rts_expected for this platform, set GODOT_BIN, then rerun setup." >&2
        exit 1
    }
    _rts_install_dir="$(dirname -- "$(dirname -- "$_rts_game_dir")")/.tools/godot-4.6.3"
    _rts_download="$(mktemp -d)"
    trap 'rm -rf -- "$_rts_download"' EXIT
    curl --fail --location --retry 3 --output "$_rts_download/godot.zip" \
        https://github.com/godotengine/godot-builds/releases/download/4.6.3-stable/Godot_v4.6.3-stable_linux.x86_64.zip
    # Pinned SHA-512 from the official release's SHA512-SUMS.txt, fetched over verified TLS.
    printf '%s  %s\n' \
        a035258da32b77f966a5376f9fa29c30a6adde826a85ba918e1605bd1fc9823eba7d85f1dd5e748956bd2ba72827c0025ffa11bb82aec91128c407a2e723c99c \
        "$_rts_download/godot.zip" | sha512sum --check --status
    mkdir -p -- "$_rts_install_dir"
    unzip -q "$_rts_download/godot.zip" -d "$_rts_download/extracted"
    install -m 755 "$_rts_download/extracted/Godot_v4.6.3-stable_linux.x86_64" "$_rts_install_dir/godot"
    export GODOT_BIN="$_rts_install_dir/godot"
fi
[[ "$("$GODOT_BIN" --headless --version)" == "$_rts_expected" ]] || {
    echo "Godot version mismatch: required $_rts_expected" >&2
    exit 1
}
"$GODOT_BIN" --headless --path "$_rts_game_dir" --import
"$_rts_game_dir/tools/test.sh"
