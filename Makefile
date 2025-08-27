SHELL := /usr/bin/env bash
VENV := .venv
PY := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

.PHONY: init test clean

init:
	@bash scripts/setup.sh

test:
	@source $(VENV)/bin/activate >/dev/null 2>&1 && \
	if command -v xvfb-run >/dev/null 2>&1; then \
		xvfb-run -a python -m pytest -q; \
	else \
		python -m pytest -q; \
	fi

clean:
	rm -rf $(VENV) .pytest_cache .coverage dist build artifacts

