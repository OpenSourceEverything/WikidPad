## Makefile: developer entrypoints
## - init/test/lint/run common tasks
## - docker-matrix: run CI across distros listed in scripts/distros.list
SHELL := /usr/bin/env bash
VENV ?= .venv
PY := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

.PHONY: init test tests test-install test-release test-all list-tests \
        clean run install-user uninstall-user build-bin docker-matrix \
        docker-ci lint format ci release

init:
	@bash scripts/setup.sh

test:
	@source $(VENV)/bin/activate >/dev/null 2>&1 && \
	if command -v xvfb-run >/dev/null 2>&1 && command -v xauth >/dev/null 2>&1; then \
		xvfb-run -a python -m pytest -q; \
	elif [[ -e scripts/xvfb-run ]]; then \
		bash scripts/xvfb-run python -m pytest -q; \
	else \
		python -m pytest -q; \
	fi

tests: test test-install

test-install:
	@bash scripts/test_install.sh

test-release:
	@bash scripts/test_release.sh $(if $(VERSION),$(VERSION),)

# Full local suite (no Docker). Optional: WITH_RELEASE=1 to include release dry-run
test-all:
	@$(MAKE) ci
	@$(MAKE) test-install
	@if [[ "$(WITH_RELEASE)" == "1" ]]; then \
		$(MAKE) test-release $(if $(VERSION),VERSION=$(VERSION),); \
	else \
		echo "[test-all] skipping release dry-run (set WITH_RELEASE=1 to include)"; \
	fi

list-tests:
	@sed -n '1,200p' docs/TESTING.md | sed -n '/^## Suite/,/^## /p' || true

clean:
	chmod -R u+w $(VENV) >/dev/null 2>&1 || true
	rm -rf $(VENV) .pytest_cache .coverage dist build artifacts || true
	@if [ -d $(VENV) ]; then \
		echo "Could not remove $(VENV). If it was created in a container as root, run:"; \
		echo "  sudo rm -rf $(VENV)"; \
	fi

run:
	@scripts/wikidpad --wiki $(WIKI)

install-user:
	@bash scripts/install-user.sh

uninstall-user:
	@bash scripts/uninstall-user.sh

build-bin:
	@bash scripts/build-pyinstaller.sh

release:
	@bash scripts/release.sh $(if $(VERSION),--version $(VERSION),) $(if $(SIGN),--sign,)

# Run CI across the Linux matrix defined in scripts/distros.list.
# Usage:
#   make docker-matrix                 # run all distros
#   make docker-matrix ONLY=name       # run a single distro by name
#   make docker-matrix LIST=1          # list targets (name + image)
# Notes:
#   - scripts/docker_matrix.sh reads scripts/distros.list (name image)
#   - results are collected under artifacts-matrix/<name>/
docker-matrix:
	@bash scripts/docker_matrix.sh $(if $(LIST),--list,) $(if $(ONLY),--only $(ONLY),)

# Back-compat: keep docker-ci as an alias to the full matrix.
# This ensures CI defaults to testing all distros, not just one.
docker-ci: docker-matrix

lint:
	@source $(VENV)/bin/activate >/dev/null 2>&1 || true; \
	if ! command -v ruff >/dev/null 2>&1; then \
		python -m pip install -U pip && pip install ruff black; \
	fi; \
	bash scripts/lint.sh

format:
	@source $(VENV)/bin/activate >/dev/null 2>&1 || true; \
	if ! command -v black >/dev/null 2>&1; then \
		python -m pip install -U pip && pip install black; \
	fi; \
	black .

ci:
	@echo "[ci] init" && $(MAKE) init
	@echo "[ci] lint" && $(MAKE) lint
	@echo "[ci] test" && $(MAKE) test
