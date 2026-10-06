#!/usr/bin/env python3
"""Prepare the stock Godot 4.6.3 Android exporter; no Gradle/NDK/plugins needed."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import urllib.parse
import urllib.request
import zipfile

GAME = Path(__file__).resolve().parents[1]
WORKSPACE = GAME.parent.parent
CACHE = WORKSPACE / '.tools' / 'android'
SDK = WORKSPACE / '.tools' / 'android-sdk'
ANDROID_USER = WORKSPACE / '.runtime' / 'android'
COMMANDLINE_SHA1 = '5fdcc763663eefb86a5b8879697aa6088b041e70'
TEMPLATES_SHA512 = 'da606b61c10157844f8300172df374472665f95015495cb1a7cd132c40ede404faa96cc1016a4b9662db9909ddea69632c4948b2cd11163438dad4808881fb68'
# Checksums from Google's repository2-1.xml and the official Godot SHA512-SUMS.txt.


def fetch_verified(url, path, algorithm, expected):
    if not path.exists():
        print('Downloading', path.name, flush=True)
        temporary = path.with_suffix(path.suffix + '.part')
        with urllib.request.urlopen(url, timeout=120) as response, temporary.open('wb') as target:
            shutil.copyfileobj(response, target)
        temporary.replace(path)
    with path.open('rb') as stream:
        actual = hashlib.file_digest(stream, algorithm).hexdigest()
    if actual != expected:
        raise SystemExit('Checksum mismatch: ' + path.name + '; refusing to use this artifact')
    print('Verified', path.name, flush=True)


for directory in (CACHE, SDK, ANDROID_USER):
    directory.mkdir(parents=True, exist_ok=True)
manager = SDK / 'cmdline-tools' / '19.0' / 'bin' / 'sdkmanager'
if not manager.exists():
    commandline = CACHE / 'commandline-tools.zip'
    fetch_verified('https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip',
                   commandline, 'sha1', COMMANDLINE_SHA1)
    destination = SDK / 'cmdline-tools' / '19.0'
    with zipfile.ZipFile(commandline) as archive:
        for entry in archive.infolist():
            relative = Path(entry.filename).relative_to('cmdline-tools')
            target = destination / relative
            if entry.is_dir():
                target.mkdir(parents=True, exist_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(archive.read(entry))
                if entry.external_attr >> 16:
                    target.chmod((entry.external_attr >> 16) & 0o777)

java_home = Path(os.environ.get('JAVA_HOME') or Path(shutil.which('java') or '').resolve().parents[1])
if not (java_home / 'bin' / 'java').exists() or not (java_home / 'bin' / 'keytool').exists():
    raise SystemExit('Install Java 17 or newer with java/keytool, or set JAVA_HOME to that installation')
# ANDROID_USER_HOME redirects sdkmanager's cache away from a read-only cloud home.
environment = dict(os.environ, ANDROID_USER_HOME=str(ANDROID_USER), JAVA_HOME=str(java_home))
required = [SDK / 'platform-tools' / 'adb', SDK / 'build-tools' / '36.0.0' / 'apksigner',
            SDK / 'platforms' / 'android-36' / 'android.jar']
if not all(path.exists() for path in required):
    command = [str(manager), '--sdk_root=' + str(SDK)]
    proxy = urllib.parse.urlparse(os.environ.get('HTTPS_PROXY') or os.environ.get('https_proxy', ''))
    if proxy.hostname:
        command += ['--proxy=http', '--proxy_host=' + proxy.hostname,
                    '--proxy_port=' + str(proxy.port or 80)]
    command += ['platform-tools', 'build-tools;36.0.0', 'platforms;android-36']
    # Accept toolchain licenses for the requested Android build, without interactive prompts.
    subprocess.run(command, input='y\n' * 100, text=True, env=environment, check=True)

template_dir = Path(os.environ['XDG_DATA_HOME']) / 'godot' / 'export_templates' / '4.6.3.stable'
if not all((template_dir / name).exists() for name in ('android_debug.apk', 'android_release.apk')):
    template = CACHE / 'templates.tpz'
    fetch_verified('https://github.com/godotengine/godot-builds/releases/download/4.6.3-stable/Godot_v4.6.3-stable_export_templates.tpz',
                   template, 'sha512', TEMPLATES_SHA512)
    template_dir.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(template) as archive:
        for name in ('android_debug.apk', 'android_release.apk', 'version.txt'):
            (template_dir / name).write_bytes(archive.read('templates/' + name))
print('Android SDK and matching stock export templates ready')

# EditorSettings is a native Godot text Resource. Preserve every existing setting
# and change only these two non-secret tool paths; no editor session is required.
settings_path = Path(os.environ['XDG_CONFIG_HOME']) / 'godot' / 'editor_settings-4.6.tres'
settings_path.parent.mkdir(parents=True, exist_ok=True)
contents = settings_path.read_text() if settings_path.exists() else '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n'
for name, value in [('export/android/android_sdk_path', str(SDK)),
                    ('export/android/java_sdk_path', str(java_home))]:
    lines = contents.splitlines()
    replacement = name + ' = ' + json.dumps(value)
    indices = [i for i, line in enumerate(lines) if line.startswith(name + ' =')]
    if indices:
        for index in indices:
            lines[index] = replacement
    else:
        lines.insert(lines.index('[resource]') + 1, replacement)
    contents = '\n'.join(lines) + '\n'
settings_path.write_text(contents)
print('Configured local Android/Java tool paths')
