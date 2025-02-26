import Foundation

struct SequenceShortcut: Shortcut {
  var action: Action!

  var keyCodes: [UInt32]?

  init(_ keyCodes: [UInt32]) {
    self.keyCodes = keyCodes
  }

  init(_ keyCodes: [UInt32], _ action: @escaping Action) {
    self.keyCodes = keyCodes
    self.action = action
  }
}
