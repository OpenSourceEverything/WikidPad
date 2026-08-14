import zipfile

from lib.pwiki.PluginManager import PluginManager


def test_load_zip_plugin_with_relative_import(tmp_path):
    """ZIP plugins retain their documented package and path behavior."""
    plugin_path = tmp_path / "sample.zip"
    with zipfile.ZipFile(plugin_path, "w") as archive:
        archive.writestr(
            "__init__.py",
            "from .helper import VALUE\n"
            "WIKIDPAD_PLUGIN = (('test', 1),)\n"
            "def get_value():\n"
            "    return VALUE, __zippath__\n",
        )
        archive.writestr("helper.py", "VALUE = 'loaded'\n")

    manager = PluginManager([str(tmp_path)])
    api = manager.registerSimplePluginAPI(("test", 1), ["get_value"])

    manager.loadPluginsFixed([])

    assert api.get_value() == [("loaded", str(plugin_path))]
