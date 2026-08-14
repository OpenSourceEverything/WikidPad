#!/usr/bin/env python3
"""Start WikidPad with a real disposable wiki and reject startup errors."""

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


STARTUP_TIMEOUT_SECONDS = 10
UNEXPECTED_OUTPUT = (
    "Traceback (most recent call last)",
    "SyntaxWarning:",
    "Adding duplicate image handler",
    "Adding duplicate animation handler",
    "No accel key found",
    "UnregisterHotKey' failed",
)


def stop_process(process):
    process.terminate()
    try:
        return process.communicate(timeout=5)[0]
    except subprocess.TimeoutExpired:
        process.kill()
        return process.communicate()[0]


def main():
    repo_root = Path(__file__).resolve().parents[2]
    help_source = repo_root / "WikidPad" / "WikidPadHelp"

    with tempfile.TemporaryDirectory(prefix="wikidpad-startup-") as temp_dir:
        help_copy = Path(temp_dir) / "WikidPadHelp"
        shutil.copytree(
            help_source,
            help_copy,
            ignore=shutil.ignore_patterns("*.lock", "*.sli-journal", "__pycache__"),
        )

        process = subprocess.Popen(
            [
                sys.executable,
                str(repo_root / "WikidPad.py"),
                "--wiki",
                str(help_copy / "WikidPadHelp.wiki"),
                "--no-recent",
            ],
            cwd=repo_root,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            errors="replace",
        )

        try:
            output = process.communicate(timeout=STARTUP_TIMEOUT_SECONDS)[0]
        except subprocess.TimeoutExpired:
            output = stop_process(process)
        else:
            print(output, end="")
            raise SystemExit(
                "WikidPad exited before the startup timeout "
                f"(status {process.returncode})"
            )

    found = [message for message in UNEXPECTED_OUTPUT if message in output]
    if found:
        print(output, end="")
        raise SystemExit("Unexpected startup output: " + ", ".join(found))


if __name__ == "__main__":
    main()
