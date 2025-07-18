enum SequenceShortcutNode {
  case action(key: String, action: Action)
  case group(key: String, children: [String: SequenceShortcutNode])
}

extension SequenceShortcutNode: CustomStringConvertible {
  var description: String {
    switch self {
    case .action(let key, _):
      return "Action {Key: \(key)}"
    case .group(let key, let children):
      return "Group {Key: \(key), Children: [\(childrenDescription(children))]}"
    }
  }

  private func childrenDescription(_ children: [String: SequenceShortcutNode]) -> String {
    children
      .sorted(by: { $0.key < $1.key })
      .map { "\($0.key): \($0.value.description)" }
      .joined(separator: ", ")
  }
}
