import Testing

@testable import skbdlib

@Suite("Token")
struct TokenTests {
  // MARK: Token#description

  @Test("Token#description")
  func description() async throws {
    let tests: [Token: String] = [
      Token(type: .plus): "Token {type: TokenType {+}, text: nil}",
      Token(type: .command, text: "echo \"Hello World\""):
        "Token {type: TokenType {Command}, text: echo \"Hello World\"}",
    ]

    for (token, expected) in tests {
      #expect(token.description == expected)
    }
  }
}
