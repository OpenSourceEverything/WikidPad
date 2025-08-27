import pytest

try:
    import wx
except Exception as exc:  # pragma: no cover - optional GUI
    pytest.skip(f"wx not available: {exc}", allow_module_level=True)
else:
    if not hasattr(wx, "Frame"):
        pytest.skip("wx GUI components not available", allow_module_level=True)


def test_frame_opens(wx_app, yield_fast):
    frame = wx.Frame(None, title="Smoke")
    frame.Show()
    yield_fast
    assert frame.IsShown()
    frame.Destroy()
