import Carbon
import Foundation

struct ModifierShortcut: Shortcut {
  var action: Action!

  let identifier = UUID()

  var isLeader: Bool = false

  var keyCode: UInt32
  var modifierFlags: UInt32

  init(_ keyCode: UInt32, _ modifierFlags: UInt32) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
  }

  init(_ keyCode: UInt32, _ modifierFlags: UInt32, _ action: @escaping Action) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
    self.action = action
  }
}
