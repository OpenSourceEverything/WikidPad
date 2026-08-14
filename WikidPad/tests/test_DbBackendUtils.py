from pathlib import Path
import subprocess
import sys

from tests import helper  # Sets up WikidPad's import path for pytest importlib mode.

from pwiki.wikidata import DbBackendUtils


def test_original_sqlite_handler_available():
    assert ("original_sqlite", "Original Sqlite") in DbBackendUtils.listHandlers()
    factory, create = DbBackendUtils.getHandler("original_sqlite")
    assert factory is not None
    assert create is not None


def test_sqlite_wrapper_opens_database_in_fresh_interpreter():
    wikidpad_dir = Path(__file__).resolve().parents[1]
    script = """
import sys
sys.path.insert(0, "lib")
from pwiki import SqliteThin3

database = SqliteThin3.SqliteDb3(":memory:")
try:
    database.execute("create table values_to_read (value integer)")
    database.execute("insert into values_to_read values (42)")
    statement = database.prepare("select value from values_to_read")
    try:
        assert statement.step()
        print(statement.column_auto(0))
    finally:
        statement.close()
finally:
    database.close()
"""

    result = subprocess.run(
            [sys.executable, "-S", "-c", script],
            cwd=wikidpad_dir,
            capture_output=True,
            text=True,
            check=False)

    assert result.returncode == 0, result.stdout + result.stderr
    assert result.stdout.strip() == "42"
