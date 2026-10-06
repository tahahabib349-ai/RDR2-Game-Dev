#!/usr/bin/env bash
# Source this file from any directory. Tool/cache paths stay outside the checkout.
_rts_repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
_rts_workspace_root="$(dirname -- "$_rts_repo_root")"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$_rts_workspace_root/.runtime/godot/cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$_rts_workspace_root/.runtime/godot/data}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$_rts_workspace_root/.runtime/godot/config}"
mkdir -p -- "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_CONFIG_HOME"
if [[ -x "$_rts_workspace_root/.tools/godot-4.6.3/godot" ]]; then
    export GODOT_BIN="$_rts_workspace_root/.tools/godot-4.6.3/godot"
else
    export GODOT_BIN="${GODOT_BIN:-godot}"
fi
unset _rts_repo_root _rts_workspace_root
