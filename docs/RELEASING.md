# Releasing WikidPad

This document explains what a "release" is in this repo, how to create one,
and how our CI packages artifacts in a provider‑neutral way.

Note: We currently ship Linux artifacts only. Windows and macOS releases are not supported.

## What is a Release?

- A release is a packaged, downloadable build of the app.
– We build Linux bundles using PyInstaller so users don’t need to
  install Python or dependencies.
- Artifacts:
  - Linux: `wikidpad-<version>-linux-<arch>.tar.gz`
  - Each comes with `SHA256SUMS` (and optionally `SHA256SUMS.asc`) and a `manifest.json` describing the build.

## What is a PyInstaller Bundle?

PyInstaller freezes a Python application into a self‑contained distribution
by bundling:

- The Python interpreter for the target platform
- Your code (as `.pyc` bytecode) and resources
- Third‑party libraries (e.g., `wxPython`)

This does not “compile to native code.” It packages everything together so the
user runs a single program without installing Python.

## Versioning and Tagging

- Update the version in `WikidPad/Consts.py`:
  - `VERSION_TUPLE`
  - `VERSION_STRING`
- Commit the change and create an annotated tag:

```bash
git commit -am "chore(release): v2.4.0"
git tag -a v2.4.0 -m "Release v2.4.0"
git push && git push --tags
```

Tags matching `v*` trigger the CI release pipeline.

## How CI Builds and Publishes

Provider‑neutral steps are kept in scripts; CI just calls them.

1) Build per‑OS bundle

- Linux job:
  - `bash scripts/setup.sh` (env + deps)
  - `bash scripts/build-pyinstaller.sh` (creates `dist/wikidpad/`)
  - `bash scripts/package.sh --os linux --version ${{ github.ref_name }}`

2) Artifacts

- The Linux job uploads `release/**` as a build artifact.
- A separate `publish` job (opt-in) downloads the Linux artifact and creates a
  GitHub Release attaching the packaged files.

Notes:

- Packaging logic is in `scripts/package.sh`, making migration to other CI providers straightforward.
- If you migrate to GitLab/Jenkins, call the same scripts and use the
  platform’s native API to create a release and upload the files.

## Release Notes

- Maintain `CHANGELOG.md` using the Keep a Changelog style.
- The publish step extracts the section for the tagged version via
  `scripts/release_notes.sh` and uses it as the release body.
- If no matching section exists, the whole changelog is used as a fallback.

## Auto‑Publish Gate (Optional)

- GitHub only auto‑publishes a Release when repository variable
  `PUBLISH_RELEASE` is set to `true`.
- Without it, CI still builds and uploads artifacts; you can create a
  release manually or enable publishing later.

Set the variable under: Settings → Variables → Repository variables →
`PUBLISH_RELEASE=true`.

## GPG Signatures (Optional)

You can have CI sign the checksum file with a GPG key. This helps users verify
the integrity and provenance of downloads.

- Create or choose a GPG key used for signing releases.
- Export the private key (ASCII‑armored) and add to CI secrets:
  - Secret `GPG_PRIVATE_KEY`: contents of the exported private key.
  - Secret `GPG_PASSPHRASE`: passphrase for the key (if set).
- Add repository variables:
  - `SIGN_RELEASE=true` to enable signing in CI.
  - `GPG_KEY_ID=<your-key-id>` (optional; otherwise default signing key is used).

What CI does when enabled:

- Imports the private key.
- Calls `scripts/package.sh --sign`, which creates `release/SHA256SUMS.asc` as a
  detached, armored signature over `release/SHA256SUMS`.
- The `manifest.json` includes `SHA256SUMS.asc` when present.

Manual verification example:

```bash
gpg --verify SHA256SUMS.asc SHA256SUMS
sha256sum -c SHA256SUMS  # or shasum -a 256 -c SHA256SUMS
```

## Manual Local Builds

Linux:

```bash
make init
bash scripts/build-pyinstaller.sh
bash scripts/package.sh --os linux --version 2.4.0
ls release/
```

## Best Practices

- Semantic versioning where possible: MAJOR.MINOR.PATCH
- Use annotated tags (with a message) for releases
- Always run tests locally or rely on the CI matrix before tagging
- Keep release notes human‑readable; link notable PRs and user‑visible changes
- Publish checksum files; optionally sign archives (GPG) if you maintain keys
- Verify the unpacked bundles on a clean OS VM to catch missing dependencies
- Avoid provider‑specific logic in scripts; keep it in CI glue only
