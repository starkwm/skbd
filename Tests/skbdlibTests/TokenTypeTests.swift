import Testing

@testable import skbdlib

@Suite("TokenType")
struct TokenTypeTests {
  // MARK: TokenType#description

  @Test("TokenType#description")
  func description() async throws {
    let tests: [TokenType: String] = [
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
