# Testing (what runs where)

## Suite (local defaults)

- make ci
  - init → lint (ruff, black --check) → pytest (xvfb if present)
- make test-install
  - venv exists; wx imports; launcher present/correct
- make tests
  - pytest + install sanity
- make test-all [WITH_RELEASE=1]
  - ci + install sanity; add release dry-run if WITH_RELEASE=1
- make test-release [VERSION=0.0.0-ci]
  - build PyInstaller app; package tar + SHA256SUMS(+asc) + manifest

## Docker matrix (multi-distro)

- make docker-matrix [ONLY=name]
  - runs scripts/docker_matrix.sh
  - per distro: bash scripts/os_deps.sh && make ci
  - collects artifacts under artifacts-matrix/<name>/
  - runs containers as host uid:gid to avoid permission issues

## Scheduled/Manual (CI canaries)

- wx-latest (weekly/manual)
  - WX_VERSION=latest make init; make test
  - catches regressions in upstream wx wheels
- release-canary (weekly/manual)
  - make test-release VERSION=0.0.0-ci
  - verifies build + package path
- wx-source (manual)
  - FORCE_WX_SOURCE=1 make init; make test
  - compiles wx from sdist to verify fallback path

## Notes

- Linux install path is single-source: scripts/setup.sh via make init.
- Unit/GUI behavior tests live in pytest; system/package flows in scripts.
- Local full run (no release): make test-all
- Local full run (with release): make test-all WITH_RELEASE=1 VERSION=0.0.0-ci

