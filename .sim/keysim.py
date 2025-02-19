from Cocoa import NSView, NSEventModifierFlagCapsLock, NSEventModifierFlagShift, NSEventModifierFlagControl, NSEventModifierFlagOption, NSEventModifierFlagCommand, NSEventModifierFlagFunction, NSEventModifierFlagDeviceIndependentFlagsMask, NSApplication, NSWindow, NSWindowStyleMaskTitled, NSBackingStoreBuffered, NSWindowStyleMaskClosable, NSWindowStyleMaskMiniaturizable
from PyObjCTools import AppHelper

file = open("Icarus Verilog-sim/ps2.hex", "wb")

def handleKey(code, flags, release):
    if release == None: release = not ((NSEventModifierFlagCapsLock if code == 57 else\
        NSEventModifierFlagShift if (code == 56 or code == 60) else\
        NSEventModifierFlagControl if code == 59 else\
        NSEventModifierFlagOption if (code == 58 or code == 61) else\
        NSEventModifierFlagCommand if code == 55 else 0) & flags)
    if code == 53:
        NSApplication.sharedApplication().terminate_(None)
        file.close()
        return

    if code in [55, 61, 123, 126, 124, 125]: file.write(b'\xE0')
    if release: file.write(b'\xF0')
    if code == 50: file.write(b'\x0E')
    if code == 18: file.write(b'\x16')
    if code == 19: file.write(b'\x1E')
    if code == 20: file.write(b'\x26')
    if code == 21: file.write(b'\x25')
    if code == 23: file.write(b'\x2E')
    if code == 22: file.write(b'\x36')
    if code == 26: file.write(b'\x3D')
    if code == 28: file.write(b'\x3E')
    if code == 25: file.write(b'\x46')
    if code == 29: file.write(b'\x45')
    if code == 27: file.write(b'\x4E')
    if code == 24: file.write(b'\x55')
    if code == 51: file.write(b'\x66')
    if code == 48: file.write(b'\x0D')
    if code == 12: file.write(b'\x15')
    if code == 13: file.write(b'\x1D')
    if code == 14: file.write(b'\x24')
    if code == 15: file.write(b'\x2D')
    if code == 17: file.write(b'\x2C')
    if code == 16: file.write(b'\x35')
    if code == 32: file.write(b'\x3C')
    if code == 34: file.write(b'\x43')
    if code == 31: file.write(b'\x44')
    if code == 35: file.write(b'\x4D')
    if code == 33: file.write(b'\x54')
    if code == 30: file.write(b'\x5B')
    if code == 42: file.write(b'\x5D')
    if code == 57: file.write(b'\x58')
    if code == 0: file.write(b'\x1C')
    if code == 1: file.write(b'\x1B')
    if code == 2: file.write(b'\x23')
    if code == 3: file.write(b'\x2B')
    if code == 5: file.write(b'\x34')
    if code == 4: file.write(b'\x33')
    if code == 38: file.write(b'\x3B')
    if code == 40: file.write(b'\x42')
    if code == 37: file.write(b'\x4B')
    if code == 41: file.write(b'\x4C')
    if code == 39: file.write(b'\x52')
    if code == 36: file.write(b'\x5A')
    if code == 56: file.write(b'\x12')
    if code == 6: file.write(b'\x1A')
    if code == 7: file.write(b'\x22')
    if code == 8: file.write(b'\x21')
    if code == 9: file.write(b'\x2A')
    if code == 11: file.write(b'\x32')
    if code == 45: file.write(b'\x31')
    if code == 46: file.write(b'\x3A')
    if code == 43: file.write(b'\x41')
    if code == 47: file.write(b'\x49')
    if code == 44: file.write(b'\x4A')
    if code == 60: file.write(b'\x59')
    if code == 59: file.write(b'\x14')
    if code == 58: file.write(b'\x11')
    if code == 55: file.write(b'\x1F')
    if code == 49: file.write(b'\x29')
    if code == 61: file.write(b'\x11')
    if code == 123: file.write(b'\x6B')
    if code == 126: file.write(b'\x75')
    if code == 124: file.write(b'\x74')
    if code == 125: file.write(b'\x72')
    file.flush()

class KeyboardHandler(NSView):
    def keyDown_(self, evt):
        handleKey(evt.keyCode(), evt.modifierFlags(), False)
    def keyUp_(self, evt):
        handleKey(evt.keyCode(), evt.modifierFlags(), True)
        pass
    def flagsChanged_(self, evt):
        handleKey(evt.keyCode(), evt.modifierFlags(), None)
        pass
    def acceptsFirstResponder(self):
        return True

app = NSApplication.sharedApplication()
window = NSWindow.alloc().initWithContentRect_styleMask_backing_defer_(((0, 0), (1, 0)), 1, 0, False)

view = KeyboardHandler.alloc().initWithFrame_(((0, 0), (0, 0)))
window.setContentView_(view)
window.makeKeyAndOrderFront_(None)
app.activateIgnoringOtherApps_(True)

AppHelper.runEventLoop()