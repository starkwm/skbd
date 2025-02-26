enum TokenType {
  case comment

  case leader

  case keywordStart
  case keywordEnd

  case modifier
  case key
  case command

  case plus
  case dash

  case unknown
  case endOfStream
}

extension TokenType: CustomStringConvertible {
  var description: String {
    switch self {
    case .comment:
      return "TokenType {Comment}"
    case .leader:
      return "TokenType {Leader}"
    case .keywordStart:
      return "TokenType {Keyword Start}"
    case .keywordEnd:
      return "TokenType {Keyword End}"
    case .modifier:
      return "TokenType {Modifier}"
    case .key:
      return "TokenType {Key}"
    case .command:
      return "TokenType {Command}"
    case .plus:
      return "TokenType {+}"
    case .dash:
      return "TokenType {-}"
    case .unknown:
      return "TokenType {Unknown}"
    case .endOfStream:
      return "TokenType {End of Stream}"
    }
  }
}
