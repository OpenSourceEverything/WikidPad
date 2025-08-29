# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to
Semantic Versioning where practical.

## [Unreleased]
### Added
- Provider‑neutral packaging scripts: `scripts/package.sh`, `scripts/package.ps1`.
- Release notes generator: `scripts/release_notes.sh`.
- Release documentation: `docs/RELEASING.md`.

### Changed
- CI release workflow now builds, packages, and can auto‑publish GitHub Releases.
- Added explanatory comments across CI and scripts.

### Fixed
- Headless GUI tests documentation and workflows clarified.

### Removed
- Windows/macOS release packaging and Windows CI job; Linux artifacts only.

## [2.4.0] - 2025-08-29
### Added
- Docker‑based Linux matrix runner for GUI tests.
- Headless GUI smoke tests and artifacts.

### Changed
- Centralized environment setup and wxPython pinning.

### Removed
- Legacy Dockerfile and CI shell wrappers in favor of matrix script.

[Unreleased]: https://github.com/WikidPad/WikidPad/compare/v2.4.0...HEAD
[2.4.0]: https://github.com/WikidPad/WikidPad/releases/tag/v2.4.0
