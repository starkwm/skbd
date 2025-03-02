struct Token: Hashable {
  var type: TokenType
  var text: String?

  var description: String {
    "Token {type: \(type), text: \(text ?? "nil")}"
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(type)
    hasher.combine(text)
  }
}
