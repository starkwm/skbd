class SequenceShortcutManager {
  var root: [String: SequenceShortcutNode] = [:]

  private var shortcuts: [SequenceShortcut] = []

  func register(shortcut: SequenceShortcut) {
    shortcuts.append(shortcut)
  }

  func setup() throws {
    for shortcut in shortcuts {
      try insert(shortcut: shortcut, into: &root)
    }
  }

  func reset() {
    shortcuts.removeAll()
    root.removeAll()
  }

  private func insert(shortcut: SequenceShortcut, into tree: inout [String: SequenceShortcutNode]) throws {
    guard !shortcut.keys.isEmpty else { return }

    guard let action = shortcut.action else {
      throw SequenceShortcutError.actionIsMissing
    }

    let currentKey = shortcut.keys[0]

    if shortcut.keys.count == 1 {
      tree[currentKey] = .action(key: currentKey, action: action)
      return
    }

    let remainingShortcut = SequenceShortcut(Array(shortcut.keys.dropFirst()), action)

    var children: [String: SequenceShortcutNode] = [:]

    if case .group(_, let existingChildren) = tree[currentKey] {
      children = existingChildren
    }

    try insert(shortcut: remainingShortcut, into: &children)

    tree[currentKey] = .group(key: currentKey, children: children)
  }
}
