import Testing

@testable import SkbdLib

@Suite("TokenType")
struct TokenTypeTests {
  // MARK: - TokenType#description

  @Test("TokenType#description")
  func description() async throws {
    let tests: [TokenType: String] = [
      .keywordStart: "TokenType {Keyword Start}",
      .keywordEnd: "TokenType {Keyword End}",
      .comment: "TokenType {Comment}",
      .modifier: "TokenType {Modifier}",
      .key: "TokenType {Key}",
      .command: "TokenType {Command}",
      .plus: "TokenType {+}",
      .dash: "TokenType {-}",
      .unknown: "TokenType {Unknown}",
      .endOfStream: "TokenType {End of Stream}",
    ]

    for (tokenType, expected) in tests {
      #expect(tokenType.description == expected)
    }
  }
}
