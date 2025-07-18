import Foundation

struct ModifierShortcut: HotKeyShortcut {
  var action: Action?

  let identifier = UUID()

  var keyCode: UInt32
  var modifierFlags: UInt32

  init(_ keyCode: UInt32, _ modifierFlags: UInt32, _ action: @escaping Action) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
    self.action = action
  }
}
