import Foundation

struct LeaderShortcut: HotKeyShortcut {
  var action: Action?

  let identifier = UUID()

  var keyCode: UInt32
  var modifierFlags: UInt32

  init(_ keyCode: UInt32, _ modifierFlags: UInt32) {
    self.keyCode = keyCode
    self.modifierFlags = modifierFlags
  }
}
