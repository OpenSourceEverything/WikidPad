import os
import sys
import types
from pathlib import Path

# run from WikidPad directory
wikidpad_dir = os.path.abspath('.')
sys.path.append(os.path.join(wikidpad_dir, 'lib'))
sys.path.append(wikidpad_dir)

# Minimal wx stub required for importing modules
wx = types.SimpleNamespace()
wx.OS_WINDOWS_NT = 18
wx.OS_WINDOWS_9X = 20
wx.PlatformInfo = ()
wx.GetOsVersion = staticmethod(lambda: (0,))
_orig_wx = sys.modules.get('wx')
sys.modules['wx'] = wx

from pwiki.StringOps import (
    writeEntireFile,
    loadEntireFile,
    WRITE_FILE_MODE_OVERWRITE,
)

if _orig_wx is not None:
    sys.modules['wx'] = _orig_wx
else:
    del sys.modules['wx']

def test_write_entire_file(tmp_path):
    target = tmp_path / 'töst.txt'
    writeEntireFile(str(target), b'hello', writeFileMode=WRITE_FILE_MODE_OVERWRITE)
    assert loadEntireFile(str(target)) == b'hello'

def test_write_entire_file_safe(tmp_path):
    target = tmp_path / 'safe_töst.txt'
    writeEntireFile(str(target), b'world')
    assert loadEntireFile(str(target)) == b'world'
