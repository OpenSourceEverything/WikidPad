import pathlib


def test_imghdr_compat_detects_common_formats():
    from WikidPad.lib.pwiki import _imghdr_compat as imghdr

    assert imghdr.what(None, b"\x89PNG\r\n\x1a\n" + b"0" * 24) == "png"
    assert imghdr.what(None, b"GIF89a" + b"0" * 26) == "gif"


def test_wikitxtctrl_uses_imghdr_fallback_on_py313():
    content = pathlib.Path("WikidPad/lib/pwiki/WikiTxtCtrl.py").read_text(
        encoding="utf-8"
    )
    assert "except ModuleNotFoundError" in content
    assert "from . import _imghdr_compat as imghdr" in content
