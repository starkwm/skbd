import Foundation

struct SequenceShortcut: Shortcut {
  var action: Action?

  var keys: [String]

  init(_ keys: [String], _ action: @escaping Action) {
    self.keys = keys
    self.action = action
  }
}
