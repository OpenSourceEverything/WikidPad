# Debian Packaging (Linux)

Goal: provider‑neutral .deb, separate from app CI.

Two models (both standard):

1) Packaging branch (single repo)

- Keep app on main; packaging on branch with root `debian/`.
- Steps:

```
git switch -c packaging/debian
git mv packaging/debian debian
sudo apt-get update && sudo apt-get install -y \
  build-essential debhelper-compat dh-python python3-all \
  python3-setuptools python3-wheel python3-wxgtk4.0
dpkg-buildpackage -us -uc -b
```

- Result: ../wikidpad_*.deb
- Install: `sudo apt install ../*.deb`

2) Packaging repo (two repos)

- New repo (e.g., wikidpad-debian) with root `debian/`.
- Track upstream app (submodule or gbp import).
- Build with `gbp buildpackage` or `dpkg-buildpackage`.

Notes

- Runtime depends include `python3-wxgtk4.0` to avoid wx source builds.
- Desktop entry, icon, and MIME XML provided in packaging.
- Update Maintainer/Homepage/Description in `debian/control`.
- Lint: `lintian ../*.changes`
- Sign packages (optional): configure `debsign`/GPG.

CI idea (neutral)

- Jenkins stage calls `dpkg-buildpackage` on the packaging branch.
- Artifacts archived; publishing is outside app CI.

