#!/usr/bin/env python3
"""Install only the official pinned single-threaded Web templates (no plugins)."""
import hashlib
import os
from pathlib import Path
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[3]
CACHE = ROOT / '.tools/godot-export-4.6.3'
ARCHIVE = CACHE / 'templates.tpz'
SHA512 = 'da606b61c10157844f8300172df374472665f95015495cb1a7cd132c40ede404faa96cc1016a4b9662db9909ddea69632c4948b2cd11163438dad4808881fb68'
DEST = Path(os.environ['XDG_DATA_HOME']) / 'godot/export_templates/4.6.3.stable'
NAMES = ('web_nothreads_debug.zip', 'web_nothreads_release.zip')
if not all((DEST / name).is_file() for name in NAMES):
    CACHE.mkdir(parents=True, exist_ok=True)
    if not ARCHIVE.exists():
        urllib.request.urlretrieve('https://github.com/godotengine/godot-builds/releases/download/4.6.3-stable/Godot_v4.6.3-stable_export_templates.tpz', ARCHIVE)
    with ARCHIVE.open('rb') as stream:
        digest = hashlib.file_digest(stream, 'sha512').hexdigest()
    if digest != SHA512:
        raise SystemExit('Export templates checksum mismatch; remove cached archive and retry.')
    DEST.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(ARCHIVE) as archive:
        for name in NAMES:
            (DEST / name).write_bytes(archive.read('templates/' + name))
print('Godot 4.6.3 single-threaded Web templates ready.')
