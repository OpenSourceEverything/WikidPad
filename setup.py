"""Minimal setuptools-based package config (Linux-only focus).

Removes legacy py2exe/py2app artifacts and keeps entry points for CLI.
"""

from setuptools import setup, find_packages

from WikidPad import Consts

DESCRIPTION = "Single user wiki notepad"

setup(
    name="WikidPad",
    version=Consts.VERSION_STRING.split(" ")[1] + "",
    author="Michael Butscher",
    author_email="mbutscher@gmx.de",
    description=DESCRIPTION,
    url="http://wikidpad.sourceforge.net/",
    zip_safe=False,
    keywords="Personal Wiki",
    entry_points={"gui_scripts": ["wikidpad = WikidPad.WikidPadStarter:main"]},
    package_dir={"WikidPad": "WikidPad"},
    packages=
        find_packages(include=["WikidPad*"], exclude=["WikidPad.tests"]) + [
            # Extensions (namespace packages)
            "WikidPad.extensions",
            "WikidPad.extensions.mediaWikiParser",
            "WikidPad.extensions.wikidPadParser",
            # Data folders (not true packages; may emit warnings)
            "WikidPad.lib.js",
            "WikidPad.lib.js.jquery",
            "WikidPad.icons",
            "WikidPad.WikidPadHelp",
            "WikidPad.WikidPadHelp.data",
            "WikidPad.WikidPadHelp.files",
        ],
    # wxPython is intentionally not listed in install_requires.
    # It is installed via scripts/setup.sh to ensure binary wheels are used
    # on Linux and to honor centralized version pinning.
    install_requires=[
        "six",
    ],
    include_package_data=False,
    package_data={
        "WikidPad": ["*"],
        "WikidPad.extensions": ["*"],
        "WikidPad.lib.js": ["*"],
        "WikidPad.lib.js.jquery": ["*"],
        "WikidPad.icons": ["*"],
        "WikidPad.WikidPadHelp": ["*"],
        "WikidPad.WikidPadHelp.data": ["*"],
        "WikidPad.WikidPadHelp.files": ["*"],
    },
    exclude_package_data={
        "WikidPad": ["WikidPad_Error.log", "WikidPad.config", "pytest.ini"],
        "WikidPad.tests": ["*"],
    },
    data_files=None,
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: End Users/Desktop",
        "Operating System :: OS Independent",
        "License :: OSI Approved :: BSD License",
        "Programming Language :: Python :: 3.4",
        "Topic :: Office/Business",
    ],
)
