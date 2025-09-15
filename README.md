# WikidPad

WikidPad is a wiki-like notebook for storing thoughts, ideas, todo lists,
contacts, or anything else you want to write down. This repo supports Linux,
and is written mostly in Python with wxPython for the GUI.


## Links

- Main website: http://wikidpad.sourceforge.net/
- Source repository: https://github.com/WikidPad/WikidPad/
- Docs snapshot (Wayback, May 2020):
  https://web.archive.org/web/20200502083222/https://trac.wikidpad2.webfactional.com/wiki/WikiStart

Docs in this repo:
- docs/INSTALL.md
- docs/RELEASE.md
- docs/PROJECT_FILES.md
- docs/PACKAGING_DEBIAN.md
 - docs/TESTING.md

## Prerequisites

- Python 3.10+ recommended
- wxPython 4.2.x

Note: Linux desktops require GUI libraries (e.g., `libgtk-3-0`, `libgl1`).

## Quick Start (Linux)

```
make init
scripts/wikidpad --wiki /path/YourWiki/YourWiki.wiki
```

Optional user launcher:

```
make install-user
wikidpad --wiki /path/YourWiki/YourWiki.wiki
```

More: docs/INSTALL.md

## Make targets (common)

- `make init`          Setup venv + deps
- `make run WIKI=...`  Run via launcher
- `make install-user`  Install user launcher
- `make test`          Pytests (xvfb if present)
- `make tests`         Pytests + install sanity
- `make test-install`  Install sanity only
- `make build-bin`     Build PyInstaller app
- `make release`       Build + package to release/
- `make docker-matrix` Cross-distro tests in containers

## Alternative: pipx install

```bash
pipx install .
wikidpad --wiki /path/to/YourWiki/YourWiki.wiki
```

## CI parity

- Local: `make ci`
- Docker matrix: `make docker-matrix`
- CI calls the same scripts; provider-neutral

## Testing (quick)

```
make test       # pytest
make tests      # pytest + install sanity
make test-all   # full local (set WITH_RELEASE=1 to include release dry-run)
```

More: docs/TESTING.md

- Notes:
  - wxPython version pin is centralized (see section below). Host and CI paths
    both honor it via `scripts/setup.sh` and `scripts/versions.sh`.
  - Deprecation warnings from upstream libraries may appear; tests should
    still pass.

## wx pin (Linux)

- Pin: `scripts/versions.sh` (`WX_VERSION`)
- Setup honors pin: `scripts/setup.sh`
- Latest check: weekly job (wx-latest)

## Release (Linux)

```
make release VERSION=vX.Y.Z
```

Signing: create `scripts/release.env` from example, then

```
make release VERSION=vX.Y.Z SIGN=1
```

Artifacts in `release/`. Details: docs/RELEASE.md

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
