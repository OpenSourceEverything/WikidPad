Debian packaging scaffold (optional)

How to use:

1) Copy this folder to repo root as `debian/` on a packaging branch:

   git switch -c packaging/debian
   git mv packaging/debian debian

2) Build source/binary packages (Debian/Ubuntu host):

   sudo apt-get update && sudo apt-get install -y \
     build-essential debhelper-compat dh-python python3-all \
     python3-setuptools python3-wheel \
     python3-wxgtk4.0

   dpkg-buildpackage -us -uc -b

3) Install the .deb from the parent directory with `sudo apt install ./*.deb`.

Notes:

- Runtime depends include `python3-wxgtk4.0` to avoid source builds.
- Desktop entry, icon, and MIME mapping are installed by this package.
- Adjust Maintainer, Homepage, and Description in `control` as needed.

