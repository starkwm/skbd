import Foundation

struct ModifierShortcut: HotKeyShortcut {
  let identifier = UUID()

  var keyCode: UInt32
  var modifierFlags: UInt32

  var action: Action?

  init(_ keyCode: UInt32, _ modifierFlags: UInt32, _ action: @escaping Action) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
    self.action = action
  }
}
