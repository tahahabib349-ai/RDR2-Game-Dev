# Phase 1 Android phone test

This directory contains one reviewable debug APK built with Godot **4.6.3 stable** from the
camera-fix changes in this pull request. Normal generated exports remain ignored under
`game/export/`; this APK is intentionally included so the Game Director can download it from
GitHub without installing developer tools. Debug signing keys stay outside the repository.

- App name: **Breakpoint Valley Phase 1**
- Package: `com.tahahabib.breakpointvalley.phase1`
- Version: `0.1.1-phase1` (code 1)
- Requires: **ARM64 Android 7.0 or newer**; the project performance floor remains Snapdragon
  855-class hardware or better. This cannot be installed on an iPhone.
- Built from the stock Godot template, without Gradle, plugins, combat, construction or economy.
- Verified: APK signature v2/v3, 16 KB ZIP alignment, manifest/package/SDK/architecture,
  launcher intent and landscape orientation. Scripts/scenes/resources are bundled;
  test/tool scripts and signing material are excluded.
- Not verified: installation or gameplay on a physical Android device; sustained device FPS,
  notches/rotation and gesture feel. This is a debug test build, not a Play Store release.

## Download and install on your phone

1. In this directory on GitHub, open `breakpoint-valley-phase1-debug.apk` and choose **Download
   raw file**. On a computer, you can instead transfer the downloaded APK to the phone by USB.
2. Open the downloaded APK from the phone's **Files/Downloads** app.
3. If Android asks, allow **Install unknown apps / Allow from this source** for the browser or
   Files app you used, then return and press **Install**.
4. Open **Breakpoint Valley Phase 1**. After installation you can disable that install permission.

If Android says the app is incompatible, check that the phone is ARM64 and Android 7+. If a later
test APK cannot update an existing install because its debug signature changed, uninstall the
previous test build first (that removes its local test settings).

For developers with USB debugging enabled and the phone authorized:

```bash
adb install -r builds/android/breakpoint-valley-phase1-debug.apk
```

For this build, try panning all the way to the map's four tips and edges, select/move units near
those edges, then work through the phone checklist in `game/README.md`. The thin dark border is
intentional; the camera must stop instead of continuing into empty space.

APK SHA-256 is recorded in `SHA256SUMS`. From the repository root, verify with:

```bash
sha256sum --check builds/android/SHA256SUMS
```
