#!/usr/bin/env bash
# Publish through Actions: generated Web files are uploaded, never committed.
set -euo pipefail
publish_repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
deploy_dir="$(mktemp -d)"
trap 'rm -rf "$deploy_dir"' EXIT
remote="$(git -C "$publish_repo" remote get-url origin)"
build_ref="$(git -C "$publish_repo" rev-parse HEAD)"
# Push source first. The deployment runner needs this exact source commit.
git -C "$publish_repo" cat-file -e "$build_ref:.github/workflows/publish-web.yml"
if git -C "$publish_repo" ls-remote --exit-code origin refs/heads/gh-pages > /dev/null 2>&1; then
 git clone --quiet --depth 1 --single-branch --branch gh-pages "$remote" "$deploy_dir"
else
 git -C "$deploy_dir" init --quiet -b gh-pages
 git -C "$deploy_dir" remote add origin "$remote"
fi
mkdir -p "$deploy_dir/.github/workflows"
python3 - "$publish_repo/.github/workflows/publish-web.yml" "$deploy_dir/.github/workflows/publish-web.yml" "$build_ref" <<'PY'
from pathlib import Path
import sys
Path(sys.argv[2]).write_text(Path(sys.argv[1]).read_text().replace('  BUILD_REF: main', '  BUILD_REF: ' + sys.argv[3]))
PY
git -C "$deploy_dir" add .github/workflows/publish-web.yml
if git -C "$deploy_dir" diff --cached --quiet; then
 echo 'This source commit is already queued/published. Check GitHub Actions.'
 exit 0
fi
git -C "$deploy_dir" -c user.name="$(git -C "$publish_repo" config user.name)" -c user.email="$(git -C "$publish_repo" config user.email)" commit -m 'Deploy Phase 1 Web from source without committing build files'
git -C "$deploy_dir" push origin HEAD:gh-pages
echo 'Publishing queued. Check the Publish Phase 1 Web workflow in GitHub Actions.'
