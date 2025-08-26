import time
import wx


def build_frame():
    frame = wx.Frame(None, title="Demo")
    button = wx.Button(frame, label="Click")
    text = wx.StaticText(frame, label="0")

    def on_click(evt):
        text.SetLabel("1")

    button.Bind(wx.EVT_BUTTON, on_click)
    sizer = wx.BoxSizer(wx.VERTICAL)
    sizer.Add(button)
    sizer.Add(text)
    frame.SetSizerAndFit(sizer)
    frame.Show()
    frame.Update()
    wx.Yield()
    return frame, button, text


def test_click(wx_app, yield_fast):
    frame, button, text = build_frame()
    sim = wx.UIActionSimulator()
    pos = button.GetScreenPosition() + (10, 10)
    sim.MouseMove(pos)
    sim.MouseClick(wx.MOUSE_BTN_LEFT)
    for _ in range(50):
        wx.Yield()
        if text.GetLabel() == "1":
            break
        time.sleep(0.01)
    assert text.GetLabel() == "1"
    frame.Destroy()
