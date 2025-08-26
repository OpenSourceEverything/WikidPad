import wx


def test_frame_opens(wx_app, yield_fast):
    frame = wx.Frame(None, title="Smoke")
    frame.Show()
    yield_fast
    assert frame.IsShown()
    frame.Destroy()
