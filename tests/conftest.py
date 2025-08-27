import pathlib
import time

import pytest
import wx


@pytest.fixture(scope="session", autouse=True)
def wx_app():
    app = wx.App(False)
    yield app
    app.Destroy()


@pytest.fixture()
def yield_fast():
    for _ in range(20):
        wx.Yield()
        time.sleep(0.005)


@pytest.fixture(scope="session")
def artifacts():
    path = pathlib.Path("artifacts")
    path.mkdir(exist_ok=True)
    return path


@pytest.fixture(autouse=True)
def screenshot_on_failure(request, artifacts):
    yield
    if getattr(request.node, "rep_call", None) and request.node.rep_call.failed:
        width, height = wx.DisplaySize()
        bmp = wx.Bitmap(width, height)
        mem = wx.MemoryDC(bmp)
        mem.Blit(0, 0, width, height, wx.ScreenDC(), 0, 0)
        mem.SelectObject(wx.NullBitmap)
        bmp.SaveFile(str(artifacts / f"{request.node.name}.png"),
                     wx.BITMAP_TYPE_PNG)


@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    setattr(item, f"rep_{rep.when}", rep)
