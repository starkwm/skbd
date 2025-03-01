import Foundation

struct LeaderShortcut: HotKeyShortcut {
  let identifier = UUID()

  var action: Action?

  var keyCode: UInt32
  var modifierFlags: UInt32

  init(_ keyCode: UInt32, _ modifierFlags: UInt32) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
  }
}
