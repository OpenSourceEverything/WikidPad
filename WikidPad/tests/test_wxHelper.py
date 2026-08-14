from tests import helper  # Sets up WikidPad's import path for pytest importlib mode.

import wx

from pwiki import wxHelper


def test_empty_accelerator_is_not_sent_to_wx(capfd):
    assert wxHelper.getAccelPairFromString("\t") == (None, None)
    assert "No accel key found" not in capfd.readouterr().err


def test_configured_accelerator_is_parsed():
    flags, key_code = wxHelper.getAccelPairFromString("\tCtrl-S")

    assert flags & wx.ACCEL_CTRL
    assert key_code == ord("S")


def test_hotkey_registration_does_not_unregister_a_fresh_window():
    registrations = []

    class FreshWindow:
        def RegisterHotKey(self, hotkey_id, modifiers, key_code):
            registrations.append((hotkey_id, modifiers, key_code))
            return True

    window = FreshWindow()

    assert not wxHelper.setHotKeyByString(window, 1, "")
    assert wxHelper.setHotKeyByString(window, 2, "Ctrl-S")
    assert registrations == [(2, wx.MOD_CONTROL, ord("S"))]
