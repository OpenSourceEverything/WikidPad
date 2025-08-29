import os
import stat


def test_launcher_exists_and_invokes_module():
    path = os.path.join("scripts", "wikidpad")
    assert os.path.isfile(path)
    st = os.stat(path)
    assert st.st_mode & stat.S_IXUSR
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    assert "python -m WikidPad.WikidPadStarter" in content


def test_setup_pins_wxpython():
    path = os.path.join("scripts", "setup.sh")
    assert os.path.isfile(path)
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    # Uses centralized version pin via scripts/versions.sh
    assert "scripts/versions.sh" in content
    assert (
        "wxPython==${WX_VERSION}" in content
        or "pip install -U wxPython" in content
    )


def test_setup_entrypoint_declared():
    setup_py = "setup.py"
    assert os.path.isfile(setup_py)
    with open(setup_py, "r", encoding="utf-8") as f:
        content = f.read()
    assert (
        "wikidpad = WikidPad.WikidPadStarter:main" in content
        or "'wikidpad = WikidPad.WikidPadStarter:main'" in content
    )


def test_release_workflow_present():
    path = os.path.join(".github", "workflows", "release.yml")
    assert os.path.isfile(path)


def test_makefile_has_targets():
    mf = "Makefile"
    assert os.path.isfile(mf)
    with open(mf, "r", encoding="utf-8") as f:
        content = f.read()
    for tgt in ("run:", "install-user:", "uninstall-user:", "build-bin:"):
        assert tgt in content


def test_install_user_creates_desktop_and_mime():
    path = os.path.join("scripts", "install-user.sh")
    assert os.path.isfile(path)
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    # Desktop entry creation
    assert "wikidpad.desktop" in content
    assert "MimeType=text/x-wiki;" in content
    # MIME XML registration (path or filename present)
    assert "wikidpad.xml" in content
