# Install (Linux)

Quick path.

```
make init
scripts/wikidpad --wiki /path/YourWiki/YourWiki.wiki
```

Optional user launcher.

```
make install-user
wikidpad --wiki /path/YourWiki/YourWiki.wiki
```

Notes.

- `make init` creates `.venv/`, installs wxPython (binary wheel), app.
- No raw `pip install .` on Linux; use the script to avoid source builds.
- Source build (rare): `FORCE_WX_SOURCE=1 make init`.
- System wx fallback: `USE_SYSTEM_WX=1 make init`.
- `make install-user` installs a wrapper that runs the repo's venv.
- For a standalone binary, build a release (see docs/RELEASE.md).

Tips.

- The `.wiki` file lives inside your wiki directory.
- Headless tests use Xvfb if available.
