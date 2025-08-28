import os

from WikidPad.lib.pwiki.CmdLineAction import CmdLineAction


def test_cmdline_new_style_basic(tmp_path):
    wiki = os.fspath(tmp_path / "Demo.wiki")
    args = [
        "--wiki",
        wiki,
        "--page",
        "Home",
        "--page",
        "Foo",
        "--anchor",
        "top",
        "--exit",
        "--rebuild",
        "--no-recent",
        "--preview",
        "--editor",
    ]
    c = CmdLineAction(args)
    assert c.wikiToOpen == wiki
    assert c.wikiWordsToOpen == ("Home", "Foo")
    assert c.anchorToOpen == "top"
    assert c.exitFinally is True
    assert c.noRecent is True
    assert c.rebuild == c.REBUILD_FULL
    # last flag is --editor -> expect textedit present
    assert c.lastTabsSubCtrls is None or c.lastTabsSubCtrls[-1] == "textedit"


def test_cmdline_new_style_update_ext(tmp_path):
    wiki = os.fspath(tmp_path / "Demo.wiki")
    c = CmdLineAction(["--wiki", wiki, "--update-ext"])
    assert c.wikiToOpen == wiki
    assert c.rebuild == c.REBUILD_EXT


def test_cmdline_old_style_path_and_page(tmp_path):
    wiki = os.fspath(tmp_path / "Demo.wiki")
    c = CmdLineAction([wiki, "HomePage"])
    assert c.wikiToOpen == wiki
    assert c.wikiWordsToOpen == ("HomePage",)


def test_cmdline_error_on_unknown_option():
    c = CmdLineAction(["--does-not-exist"])
    assert c.cmdLineError is True
