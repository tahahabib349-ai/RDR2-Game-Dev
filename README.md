# gh-pages (not used for publishing)

The game is published by `.github/workflows/publish-web.yml` on the `main` branch: every push
to `main` that touches `game/` runs the tests, exports the Web build and deploys it to GitHub
Pages as an artifact. Nothing on this branch is served. Old build files were removed so GitHub's
branch-based Pages build can no longer bring back an outdated version of the game.
