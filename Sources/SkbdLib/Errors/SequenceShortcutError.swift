enum SequenceShortcutError: Error {
  case actionIsMissing
}

extension SequenceShortcutError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .actionIsMissing:
      return "sequence shortcut is missing an action"
    }
  }
}
