# WikidPad

WikidPad is a wiki-like notebook for storing thoughts, ideas, todo lists,
contacts, or anything else you want to write down. It runs on Windows, Linux,
and macOS, and is written mostly in Python with wxPython for the GUI.


## Links

- Main website: http://wikidpad.sourceforge.net/
- Source repository: https://github.com/WikidPad/WikidPad/
- Downloads (Windows binary and source):
  http://sourceforge.net/projects/wikidpad/files/?source=navbar
- Docs snapshot (Wayback, May 2020):
  https://web.archive.org/web/20200502083222/https://trac.wikidpad2.webfactional.com/wiki/WikiStart


## Prerequisites

- Python 3.10+ recommended
- wxPython 4.2.x

Note: Linux desktops require GUI libraries (e.g., `libgtk-3-0`, `libgl1`).


## Quick Start (recommended)

This sets up a local virtual environment and a `wikidpad` launcher.

1) Initialize environment

```bash
make init
```

2) Run WikidPad with your wiki file

```bash
scripts/wikidpad --wiki /path/to/YourWiki/YourWiki.wiki
```

3) Optional: install a user-level launcher

```bash
make install-user
# then
wikidpad --wiki /path/to/YourWiki/YourWiki.wiki
```

Pipx (optional)

```bash
# If you prefer a pipx-managed isolated install (may be slow on Linux):
bash scripts/install-user.sh --pipx
```


## Make targets

- `make init`          Install system deps + venv (CI-friendly)
- `make test`          Run test suite (xvfb on Linux if available)
- `make lint`          Run ruff + black checks (line length 80)
- `make format`        Auto-format with black
- `make run WIKI=...`  Launch via `scripts/wikidpad`
- `make install-user`  Install user launcher (`wikidpad`)
  - Also installs a user .desktop entry and icon
  - Associates text/x-wiki with WikidPad (user scope) if possible
- `make build-bin`     Build a standalone binary (PyInstaller)
- `make docker-smoke`  Build image and run GUI smoke tests in Docker
- `make docker-ci`     Build image and run lint + tests in Docker


## Alternative: pipx install

```bash
pipx install .
wikidpad --wiki /path/to/YourWiki/YourWiki.wiki
```


## Docker smoke test (local)

Requires Docker:

```bash
bash scripts/docker_smoke.sh
# or
make docker-smoke
```


## Local CI Parity

- One command locally (host): `make ci`
- Exact CI parity in Docker: `make docker-ci`
- CI systems (GitHub Actions, Jenkins) also call `make ci` to stay
  decoupled from runner specifics.


## Testing

- Local (host):
  - Unit/GUI tests: `make test`
  - Lint only: `make lint`
  - Full gate (lint + init + tests): `make ci`
  - Run a specific test: `pytest -q tests/test_cmdline_action.py::test_cmdline_new_style_basic`

- Headless GUI (Linux):
  - `make test` uses `xvfb-run` if available; otherwise runs normally.

- CI matrix (GitHub Actions):
  - Runs on `ubuntu-22.04` and `ubuntu-24.04` (see `.github/workflows/gui.yml`).
  - Both call `make ci`. The setup script detects the distro and installs
    prebuilt wxPython wheels from the wxPython “extras” repo to avoid source
    builds and ensure stable runs.

- Docker parity:
  - Tests in Docker (full CI): `make docker-ci`
  - Minimal GUI smoke test in Docker: `make docker-smoke`
  - Docker builds include required OS GUI deps and run `make ci` inside.

- Notes:
  - wxPython version pin is centralized (see section below). Docker uses
    system wx for speed; host pinning remains consistent via `make init`.
  - Deprecation warnings from upstream libraries may appear; tests should
    still pass.


## Version Pinning (wxPython)

- Central pin: `scripts/versions.sh` (env var `WX_VERSION`, default 4.2.1)
- All flows honor the pin: `scripts/bootstrap.sh`, `scripts/setup.sh`,
  `Dockerfile` (via `ARG WX_VERSION`), and Docker scripts.
- Test against the latest weekly: `.github/workflows/wx-latest.yml`

Upgrade steps:

```bash
# Try latest in Docker (no repo changes):
WX_VERSION=latest make docker-ci

# If green, bump the pin everywhere automatically:
bash scripts/bump-wx.sh 4.2.2

# Verify in Docker:
make docker-ci
```


## Cheat Sheet

```bash
# Setup
make init

# Run
scripts/wikidpad --wiki /path/to/YourWiki/YourWiki.wiki

# Install user launcher
make install-user
wikidpad --wiki /path/to/YourWiki/YourWiki.wiki

# CI locally (host)
make ci

# CI locally (Docker parity)
make docker-ci

# Lint/format
make lint
make format

# Build binary
make build-bin
```


## Notes

- The command-line accepts either a bare wiki file path (old style) or
  `--wiki /path/to/YourWiki.wiki` (new style). Use the `.wiki` file inside
  your wiki directory.
- GTK warnings like "No accel key found" and size assertions can occur on
  some Linux setups and are typically harmless.


## License

The core WikidPad project is licensed under the BSD 3-Clause License.
See the `LICENSE` file for details. Some included or required components
are under their own licenses.
