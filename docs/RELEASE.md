# Release (Linux)

Standard.

- CI releases are triggered by a tag `vX.Y.Z`.
- CI runs `scripts/release.sh --version vX.Y.Z`.
- Artifacts land in `release/`.

Local (optional).

```
make release VERSION=vX.Y.Z
```

Signing.

- Create `scripts/release.env` from `scripts/release.env.example`.
- Add: `GPG_PRIVATE_KEY`, `GPG_KEY_ID`, `GPG_PASSPHRASE`.
- Run: `make release VERSION=vX.Y.Z SIGN=1`.

Artifacts.

- `<name>-<version>-linux-<arch>.tar.gz`
- `SHA256SUMS`: integrity checksums.
- `SHA256SUMS.asc`: optional GPG signature of checksums.
- `manifest.json`: machine-readable list of files.

Verify.

```
cd release
sha256sum -c SHA256SUMS    # integrity
gpg --verify SHA256SUMS.asc SHA256SUMS   # authenticity (if present)
```

Use tarball.

```
tar -xzf wikidpad-<ver>-linux-<arch>.tar.gz
cd wikidpad
./wikidpad --wiki /path/YourWiki/YourWiki.wiki
```

Dry run.

```
make test-release VERSION=0.0.0-ci
```

Publish.

- Local directory:

```
scripts/publish.sh --target local --dest /srv/www/downloads --version vX.Y.Z
```

- SSH server (rsync over ssh):

```
scripts/publish.sh --target ssh --dest user@host:/var/www/downloads --version vX.Y.Z
```

- GitHub Release (optional):

```
GH_TOKEN=... scripts/publish.sh --target github --version vX.Y.Z \
  --notes release-assets/RELEASE_NOTES.md
```

Notes.

- Provider-neutral: same script works locally, Jenkins, or other CI.
- GitHub path uses the open-source gh CLI; optional and isolated.
