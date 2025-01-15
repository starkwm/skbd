struct Token {
  var type: TokenType
  var text: String?

  var description: String {
    "Token {type: \(type), text: \(text ?? "nil")}"
  }
}
