#!/usr/bin/env bash
# Central version pins for developer tooling

# wxPython version pin. Override by exporting WX_VERSION before calling scripts.
if [[ -z "${WX_VERSION:-}" ]]; then
  WX_VERSION="4.2.3"
fi
