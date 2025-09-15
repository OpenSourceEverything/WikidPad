# Project Files (what they do)

- pyproject.toml
  - Tool config only (ruff, black). No build settings here.

- tox.ini
  - Defines `tox -e py3` (pytest) and `tox -e lint` (ruff+black).
  - Mirrors `make test` and `make lint`.

- meta.yaml
  - Conda recipe (optional packaging). Entry point: `wikidpad`.
  - Pins wxpython >= 4.0.3 in conda context only.

- Makefile
  - Canonical targets: init, test, tests, release, docker-matrix, etc.

- scripts/
  - setup.sh       Prepare env (wx, deps, install app).
  - wikidpad       CLI launcher.
  - build-pyinstaller.sh  Build binary app.
  - package.sh     Tar + checksums (+gpg) + manifest.
  - release.sh     One-shot: setup → build → package.
  - test_install.sh  Sanity: venv, wx import, launcher.
  - test_release.sh  Dry-run release.
  - os_deps.sh     OS packages (GUI libs, optional dev headers).
  - versions.sh    wx pin.

- .github/workflows/
  - Minimal wrappers calling Make/scripts (Linux-only).

- Jenkinsfile / .gitlab-ci.yml
  - Call the same scripts for parity.

- Debian packaging
  - Scaffold under `packaging/debian/` (inactive by default).
  - Details: docs/PACKAGING_DEBIAN.md
