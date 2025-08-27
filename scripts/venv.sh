set -euo pipefail

# Use system site-packages so the apt wx module is visible inside the venv
python3 -m venv .venv --system-site-packages
. .venv/bin/activate
python -m pip install -U pip wheel
