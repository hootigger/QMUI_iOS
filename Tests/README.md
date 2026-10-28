# Theme input KVC regression

`ThemeTextInputKVC.m` exercises the actual `qmui_themeDidChangeByManager:identifier:theme:`
implementation. A view reports itself as UITextField without exposing textContainer
(as FlutterSecureTextInputView does); the test asserts no KVC read occurs. A second
view exposes a textContainer getter and asserts the refresh still reads it.

Build QMUIKit for an arm64 simulator first, then compile this fixture with the
iPhoneSimulator SDK, ARC and modules, linking UIKit, Foundation and that built
QMUIKit.framework. Add its parent directory as both a framework search path and
runtime rpath, ad-hoc sign the executable, then run it with
`xcrun simctl spawn <booted-device-id> <executable>`.

Validated on Xcode 27.1 / iOS 27.1 / arm64 iPhone Duo. This fixture does not replace
interactive checks of Flutter password entry and password autofill.
