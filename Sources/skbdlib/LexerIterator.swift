struct LexerIterator: IteratorProtocol {
  private let lexer: Lexer
  private var prevToken: Token?

  init(lexer: Lexer) {
    self.lexer = lexer
  }

  mutating func next() -> Token? {
    let token = lexer.nextToken(prevToken: prevToken)
    prevToken = token
    return token.type == .endOfStream ? nil : token
  }
}
