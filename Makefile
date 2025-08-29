SHELL := /usr/bin/env bash
VENV := .venv
PY := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

.PHONY: init test clean run install-user uninstall-user build-bin docker-smoke docker-ci lint format ci

init:
	@bash scripts/setup.sh

test:
	@source $(VENV)/bin/activate >/dev/null 2>&1 && \
	if command -v xvfb-run >/dev/null 2>&1; then \
		xvfb-run -a python -m pytest -q; \
	elif [[ -e scripts/xvfb-run ]]; then \
		bash scripts/xvfb-run python -m pytest -q; \
	else \
		python -m pytest -q; \
	fi

clean:
	rm -rf $(VENV) .pytest_cache .coverage dist build artifacts

run:
	@scripts/wikidpad --wiki $(WIKI)

install-user:
	@bash scripts/install-user.sh

uninstall-user:
	@bash scripts/uninstall-user.sh

build-bin:
	@bash scripts/build-pyinstaller.sh

docker-smoke:
	@bash scripts/docker_smoke.sh

docker-ci:
	@bash scripts/docker_ci.sh

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
	@echo "[ci] lint" && $(MAKE) lint
	@echo "[ci] init" && $(MAKE) init
	@echo "[ci] test" && $(MAKE) test
