import Testing

@testable import SkbdLib

@Suite("Lexer")
struct LexerTests {
  // MARK: - Lexer#nextToken

  @Test("Lexer#nextToken() (with valid input)")
  func nextTokenWithValidInput() async throws {
    let input = """
          leader: ctrl - space

          # this if the first comment
          opt-space: open -a iTerm2.app

          # this is a comment
          # with multiple lines... + - ++
          cmd + shift - a : echo "Hello world"

          # this is another comment, followed by a multiline command
          ctrl + opt - return : echo "foo bar"; \\
              rm -fr /

          # this is a key mapping with a number
          cmd + opt - 5: cat ~/.config/skbd/skbdrc | pbcopy

          # this is a key mapping with a non-alphanumeric key
          hyper - `: echo "backtick"

          # this makes sure we allow - as a key
          cmd + shift + opt - -: echo "hyphen!"

          # this is a leader key mapping with a single key
          <leader> a: echo "Hello"

          # this is a leader key mapping with a group key
          <leader> b c: echo "Hello"

          # this is a leader key mapping with a same group key
          <leader> b d: echo "Hello"
      """

    let expected: [TokenType] = [
      .leader, .modifier, .dash, .key,
      .comment,
      .modifier, .dash, .key, .command,
      .comment,
      .comment,
      .modifier, .plus, .modifier, .dash, .key, .command,
      .comment,
      .modifier, .plus, .modifier, .dash, .key, .command,
      .comment,
      .modifier, .plus, .modifier, .dash, .key, .command,
      .comment,
      .modifier, .dash, .key, .command,
      .comment,
      .modifier, .plus, .modifier, .plus, .modifier, .dash, .dash, .command,
      .comment,
      .keywordStart, .leader, .keywordEnd, .key, .command,
      .comment,
      .keywordStart, .leader, .keywordEnd, .key, .key, .command,
      .comment,
      .keywordStart, .leader, .keywordEnd, .key, .key, .command,
    ]

    let lexer = Lexer(input)
    let actual = lexer.map(\.type)

    #expect(expected == actual)
  }

  @Test("Lexer#nextToken() (with unknown token in input)")
  func nextTokenWithUnknownToken() async throws {
    let lexer = Lexer("@")
    let token = lexer.nextToken()

    #expect(token.type == .unknown)
  }

  @Test("Lexer#nextToken() (with unknown identifier token in input")
  func nextTokenWithUnknownIdentifierToken() async throws {
    let lexer = Lexer("cmd - f100: ls")

    let expected: [TokenType] = [
      .modifier, .dash, .unknown, .command,
    ]

    let actual = lexer.map(\.type)

    #expect(expected == actual)
  }
}
