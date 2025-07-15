import Carbon

public class SequenceShortcutManager {
  private var root: [String: SequenceShortcutNode] = [:]

  private var state = SequenceShortcutState()

  private var window: KeyWindow!

  public init() {
    DispatchQueue.main.async {
      self.window = KeyWindow(handleKey: self.handle)
    }
  }

  func register(shortcut: SequenceShortcut) throws {
    try insert(shortcut: shortcut, into: &root)
  }

  func reset() {
    state.reset()
    root.removeAll()
  }

  func listen() {
    window.isVisible ? window.hide() : window.show()
  }

  func handle(_ keyCode: UInt16) {
    if keyCode == UInt16(kVK_Escape) {
      window.hide()
      return
    }

    if keyCode == UInt16(kVK_Delete) {
      state.reset()
      return
    }

    guard let keys = Key.keys(for: keyCode) else { return }

    let list = state.currentGroup ?? root

    switch keys.compactMap({ list[$0] }).first {
    case .group(let key, let children):
      print("Group: \(key), \(children)")
      state.navigationTo(group: children)
    case .action(let key, let action):
      print("Action: \(key)")
      try? action()
      window.hide()
      state.reset()
    case .none:
      window.flash()
    }
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
