# gh-pages (publishing runner only)

Nothing on this branch is served. It only holds `.github/workflows/publish-web.yml`, because
GitHub Pages in this repository accepts deployments only from this branch.

Every push to `main` that touches `game/` triggers that workflow on `main`, which asks GitHub to
run it here for the pushed commit. The run checks out that commit, runs the full test suite,
exports the Web build and deploys it to GitHub Pages as an artifact. Nothing is pushed to this
branch to publish, so GitHub's branch-based Pages build doesn't run and can't bring back an old
version. Keep this workflow file identical to the copy on `main`.
