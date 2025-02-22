import Testing

@testable import skbdlib

@Suite("TokenType")
struct TokenTypeTests {
  x: - TokenType#description

  @Test("TokenType#description")
  func description() async throws {
    let tests: [TokenType: String] = [
      .leader: "TokenType {Leader}",
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
