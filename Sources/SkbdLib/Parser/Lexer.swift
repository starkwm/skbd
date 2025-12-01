class Lexer {
  private enum Special {
    static let null = Character("\0")
    static let backslash = Character("\\")
    static let comment = Character("#")
    static let plus = Character("+")
    static let dash = Character("-")
    static let keywordStart = Character("<")
    static let keywordEnd = Character(">")
    static let colon = Character(":")

    static let singleCharKeys: Set<Character> = ["`", "=", "[", "]", ";", "'", "\\", ",", ".", "/"]
  }

  private var buffer: String
  private var currentIndex: String.Index
  private var current: Character

  private var isAtEnd: Bool { currentIndex >= buffer.endIndex }

  init(_ buffer: String) {
    self.buffer = buffer
    self.currentIndex = buffer.startIndex
    self.current = buffer.isEmpty ? Special.null : buffer[currentIndex]
  }

  func nextToken(prevToken: Token? = nil) -> Token {
    skipWhitespace()

    guard current != Special.null else {
      return Token(type: .endOfStream)
    }

    return getToken(prevToken: prevToken)
  }

  private func getToken(prevToken: Token?) -> Token {
    switch current {
    case Special.comment:
      skipComment()
      return Token(type: .comment)

    case Special.colon:
      return handleColon(prevToken: prevToken)

    case Special.plus:
      advance()
      return Token(type: .plus)

    case Special.dash:
      advance()
      return Token(type: .dash)

    case Special.keywordStart:
      advance()
      return Token(type: .keywordStart)

    case Special.keywordEnd:
      advance()
      return Token(type: .keywordEnd)

    case _ where Special.singleCharKeys.contains(current):
      return handleSingleCharKey()

    case _ where current.isLetter || current.isNumber:
      return handleIdentifier()

    default:
      return Token(type: .unknown, text: String(current))
    }
  }

  private func advance() {
    currentIndex = buffer.index(after: currentIndex)
    current = currentIndex < buffer.endIndex ? buffer[currentIndex] : Special.null
  }

  private func skipWhitespace() {
    while !isAtEnd && current.isWhitespace {
      advance()
    }
  }

  private func skipComment() {
    while !isAtEnd && !current.isNewline {
      advance()
    }
  }

  private func handleColon(prevToken: Token?) -> Token {
    advance()
    skipWhitespace()

    let cmd = readCommand()
    return Token(type: .command, text: cmd)
  }

  private func handleSingleCharKey() -> Token {
    let key = String(current)
    advance()
    return Token(type: .key, text: key)
  }

  private func handleIdentifier() -> Token {
    let text = readIdentifier()
    let type = resolveIdentifierType(identifier: text)
    return Token(type: type, text: text)
  }

  private func readCommand() -> String {
    let start = currentIndex

    while !isAtEnd && !current.isNewline {
      if current == Special.backslash {
        advance()
      }

      advance()
    }

    return String(buffer[start..<currentIndex])
  }

  private func readIdentifier() -> String {
    let start = currentIndex

    while !isAtEnd && (current.isLetter || current.isNumber || current == "_") {
      advance()
    }

    return String(buffer[start..<currentIndex])
  }

  private func resolveIdentifierType(identifier: String) -> TokenType {
    switch identifier {
    case _ where Key.valid(identifier):
      return .key
    case _ where Modifier.valid(identifier):
      return .modifier
    default:
      return .unknown
    }
  }
}

extension Lexer: Sequence {
  func makeIterator() -> LexerIterator {
    LexerIterator(lexer: self)
  }
}
