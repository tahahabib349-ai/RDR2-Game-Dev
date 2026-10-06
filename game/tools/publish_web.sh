#!/usr/bin/env bash
# Publish the reviewed local export; requires GitHub push access and configured git identity.
set -euo pipefail
publish_repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
site="$publish_repo/game/export/web"
test -s "$site/index.html"
test -s "$site/index.wasm"
deploy_dir="$(mktemp -d)"
trap 'rm -rf "$deploy_dir"' EXIT
remote="$(git -C "$publish_repo" remote get-url origin)"
if git -C "$publish_repo" ls-remote --exit-code origin refs/heads/gh-pages > /dev/null 2>&1; then
 git clone --quiet --depth 1 --single-branch --branch gh-pages "$remote" "$deploy_dir"
else
 git -C "$deploy_dir" init --quiet -b gh-pages
 git -C "$deploy_dir" remote add origin "$remote"
fi
# gh-pages is dedicated to generated game files, never source or signing credentials.
find "$deploy_dir" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf -- {} +
cp -a "$site/." "$deploy_dir/"
printf '%s\n' "$(git -C "$publish_repo" rev-parse HEAD)" > "$deploy_dir/source-commit.txt"
git -C "$deploy_dir" add .
git -C "$deploy_dir" -c user.name="$(git -C "$publish_repo" config user.name)" -c user.email="$(git -C "$publish_repo" config user.email)" commit -m 'Publish Phase 1 single-threaded Web build'
git -C "$deploy_dir" push origin HEAD:gh-pages
