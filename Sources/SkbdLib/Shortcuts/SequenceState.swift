class SequenceState {
  var currentGroup: [String: SequenceShortcutNode]?

  func reset() {
    currentGroup = nil
  }

  func navigationTo(group: [String: SequenceShortcutNode]) {
    currentGroup = group
  }
}
