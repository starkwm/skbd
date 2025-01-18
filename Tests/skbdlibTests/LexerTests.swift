import Testing

@testable import skbdlib

@Suite("Lexer")
struct LexerTests {
  // MARK: Lexer#getToken

  @Test("Lexer#getToken() (with valid input)")
  func getTokenWithValidInput() async throws {
    let input = """
          # this if the first comment
          opt-space: open -a iTerm2.app

          # this is a comment
          # with multiple lines... + - ++
          cmd + shift - a : echo "Hello world"

          # this is another comment, followed by a multiline command
          ctrl + opt - return : echo "foo bar"; \
              rm -fr /

          # this is a key mapping with a number
          cmd + opt - 5: cat ~/.config/skbd/skbdrc | pbcopy

          # this is a key mapping with a non-alphanumeric key
          hyper - `: echo "backtick"

          # this makes sure we allow - as a key
          cmd + shift + opt - -: echo "hyphen!"

          # this uses the modifier symbols
          ⌃ + ⇧ + ⌥ + ⌘ - A: echo "symbols"
      """

    let expected: [TokenType] = [
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
      .modifier, .plus, .modifier, .plus, .modifier, .plus, .modifier, .dash, .key, .command,
      .endOfStream,
    ]

    let lexer = Lexer(input)

    for type in expected {
      let token = lexer.getToken()
      #expect(token.type == type)
    }
  }

  @Test("Lexer#getToken() (with unknown token in input)")
  func getTokenWithUnknownToken() async throws {
    let lexer = Lexer("@")
    let token = lexer.getToken()

    #expect(token.type == .unknown)
  }

  @Test("Lexer#getToken() (with unknown identifier token in input")
  func getTokenWithUnknownIdentifierToken() async throws {
    let lexer = Lexer("cmd - f100: ls")

    let expected: [TokenType] = [
      .modifier, .dash, .unknown, .command,
    ]

    for type in expected {
      let token = lexer.getToken()
      #expect(token.type == type)
    }
  }
}
