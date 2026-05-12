import Carbon
import Testing

@testable import SkbdCore

@Suite("Parser")
struct ParserTests {
  @Test("parse(): key")
  func parseKey() async throws {
    let input = """
      space: echo "space"
      a: echo "a"
      0x31: echo "space hex"
      """

    let parser = Parser(with: input)
    let result = parser.parse()
    let configuration = try result.get()

    #expect(configuration.hotKeys.count == 3)
    #expect(configuration.blockList.isEmpty)

    #expect(configuration.hotKeys[0].key == 49)
    #expect(configuration.hotKeys[0].modifierFlags == [])
    #expect(configuration.hotKeys[0].command == "echo \"space\"")

    #expect(configuration.hotKeys[1].key == 0)
    #expect(configuration.hotKeys[1].modifierFlags == [])
    #expect(configuration.hotKeys[1].command == "echo \"a\"")

    #expect(configuration.hotKeys[2].key == 0x31)
    #expect(configuration.hotKeys[2].modifierFlags == [])
    #expect(configuration.hotKeys[2].command == "echo \"space hex\"")
  }

  @Test("parse(): single modifier")
  func parseSingleModifier() async throws {
    let input = """
      lctrl - space: echo "space"
      rcmd - a: echo "a"
      alt - 0x31: echo "space hex"
      """

    let parser = Parser(with: input)
    let result = parser.parse()
    let configuration = try result.get()

    #expect(configuration.hotKeys.count == 3)
    #expect(configuration.blockList.isEmpty)

    #expect(configuration.hotKeys[0].key == kVK_Space)
    #expect(configuration.hotKeys[0].modifierFlags == .lctrl)
    #expect(configuration.hotKeys[0].command == "echo \"space\"")

    #expect(configuration.hotKeys[1].key == kVK_ANSI_A)
    #expect(configuration.hotKeys[1].modifierFlags == .rcmd)
    #expect(configuration.hotKeys[1].command == "echo \"a\"")

    #expect(configuration.hotKeys[2].key == kVK_Space)
    #expect(configuration.hotKeys[2].modifierFlags == .alt)
    #expect(configuration.hotKeys[2].command == "echo \"space hex\"")
  }

  @Test("parse(): multiple modifiers")
  func parseMultipleModifiers() async throws {
    let input = """
      lctrl + lshift - space: echo "space"
      rcmd + lcmd + rshift - a: echo "a"
      fn + alt - 0x31: echo "space hex"
      """

    let parser = Parser(with: input)
    let result = parser.parse()
    let configuration = try result.get()

    #expect(configuration.hotKeys.count == 3)
    #expect(configuration.blockList.isEmpty)

    #expect(configuration.hotKeys[0].key == kVK_Space)
    #expect(configuration.hotKeys[0].modifierFlags == [.lctrl, .lshift])
    #expect(configuration.hotKeys[0].command == "echo \"space\"")

    #expect(configuration.hotKeys[1].key == kVK_ANSI_A)
    #expect(configuration.hotKeys[1].modifierFlags == [.rcmd, .lcmd, .rshift])
    #expect(configuration.hotKeys[1].command == "echo \"a\"")

    #expect(configuration.hotKeys[2].key == kVK_Space)
    #expect(configuration.hotKeys[2].modifierFlags == [.fn, .alt])
    #expect(configuration.hotKeys[2].command == "echo \"space hex\"")
  }

  @Test("parse(): key with implicit fn modifier")
  func parseKeyWithImplicitFnModifier() async throws {
    let input = """
      lctrl - up: echo "lctrl + up"
      """

    let parser = Parser(with: input)
    let result = parser.parse()
    let configuration = try result.get()

    #expect(configuration.hotKeys.count == 1)
    #expect(configuration.blockList.isEmpty)

    #expect(configuration.hotKeys[0].key == kVK_UpArrow)
    #expect(configuration.hotKeys[0].modifierFlags == [.lctrl, .fn])
    #expect(configuration.hotKeys[0].command == "echo \"lctrl + up\"")
  }

  @Test("parse(): command with multiple lines")
  func parseCommandWithMultipleLines() async throws {
    let input = """
      lctrl - up: echo \\
      "lctrl + up"
      """

    let parser = Parser(with: input)
    let result = parser.parse()
    let configuration = try result.get()

    #expect(configuration.hotKeys.count == 1)
    #expect(configuration.blockList.isEmpty)

    #expect(configuration.hotKeys[0].key == kVK_UpArrow)
    #expect(configuration.hotKeys[0].modifierFlags == [.lctrl, .fn])
    #expect(
      configuration.hotKeys[0].command == """
        echo \\
        "lctrl + up"
        """
    )
  }

  @Test("parse(): passthrough arrow")
  func parseWithPassthroughArrow() async throws {
    let input = """
      lctrl - space-> echo "space passthrough"
      rcmd - a: echo "a consumed"
      """

    let parser = Parser(with: input)
    let result = parser.parse()
    let configuration = try result.get()

    #expect(configuration.hotKeys.count == 2)
    #expect(configuration.blockList.isEmpty)

    #expect(configuration.hotKeys[0].key == kVK_Space)
    #expect(configuration.hotKeys[0].modifierFlags == .lctrl)
    #expect(configuration.hotKeys[0].command == "echo \"space passthrough\"")
    #expect(configuration.hotKeys[0].passthrough == true)

    #expect(configuration.hotKeys[1].key == kVK_ANSI_A)
    #expect(configuration.hotKeys[1].modifierFlags == .rcmd)
    #expect(configuration.hotKeys[1].command == "echo \"a consumed\"")
    #expect(configuration.hotKeys[1].passthrough == false)
  }

  @Test("parse(): invalid input")
  func parseInvalidInput() async throws {
    let parser = Parser(with: "iterm: open -a iTerm2.app")
    let result = parser.parse()
    let isExpectedFailure =
      if case .failure(.expectedModifierOrKey) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseHotKey(): missing dash between modifier and key")
  func parseMissingDashBetweenModifierAndKey() async throws {
    let parser = Parser(with: "ctrl a: open -a iTerm2.app")
    let result = parser.parse()
    let isExpectedFailure =
      if case .failure(.expectedDashAfterModifier) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseHotKey(): missing command")
  func parseMissingCommand() async throws {
    let parser = Parser(with: "ctrl + shift - a")
    let result = parser.parse()
    let isExpectedFailure =
      if case .failure(.expectedCommandAfterKey) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseBlocklist(): process names")
  func parseBlocklist() async throws {
    let input = """
      .blocklist [
        "process1"
        "process2"
        "process3"
      ]
      """

    let parser = Parser(with: input)
    let result = parser.parse()
    let configuration = try result.get()

    #expect(configuration.hotKeys.isEmpty)
    #expect(configuration.blockList == ["process1", "process2", "process3"])
  }

  @Test("parseBlocklist(): with hotkeys")
  func parseBlocklistWithHotkeys() async throws {
    let input = """
      .blocklist [
        "Safari"
        "Terminal"
      ]
      lctrl - space: echo "space"
      """

    let parser = Parser(with: input)
    let result = parser.parse()
    let configuration = try result.get()

    #expect(configuration.hotKeys.count == 1)
    #expect(configuration.blockList == ["Safari", "Terminal"])

    #expect(configuration.hotKeys[0].key == kVK_Space)
    #expect(configuration.hotKeys[0].modifierFlags == .lctrl)
    #expect(configuration.hotKeys[0].command == "echo \"space\"")
  }

  @Test("parseBlocklist(): invalid directive")
  func parseInvalidDirective() async throws {
    let input = """
      .invalid [
        "process1"
      ]
      """

    let parser = Parser(with: input)

    let result = parser.parse()
    let isExpectedFailure = if case .failure(.invalidDirective) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseBlocklist(): missing right bracket")
  func parseBlocklistMissingBracket() async throws {
    let input = """
      .blocklist [
        "process1"
      """

    let parser = Parser(with: input)

    let result = parser.parse()
    let isExpectedFailure = if case .failure(.expectedRightBracket) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseBlocklist(): non-string process name")
  func parseBlocklistWithNonString() async throws {
    let input = """
      .blocklist [
        process1
      ]
      """

    let parser = Parser(with: input)

    let result = parser.parse()
    let isExpectedFailure =
      if case .failure(.expectedStringLiteral) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseBlocklist(): missing left bracket")
  func parseBlocklistMissingLeftBracket() async throws {
    let input = ".blocklist process1"

    let parser = Parser(with: input)

    let result = parser.parse()
    let isExpectedFailure =
      if case .failure(.expectedLeftBracketAfterDirective) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseBlocklist(): directive nil text")
  func parseBlocklistDirectiveNilText() async throws {
    let parser = Parser(
      with: FakeLexer(tokens: [
        Token(type: .directive, text: nil), Token(type: .beginList), Token(type: .endList),
      ])
    )
    let result = parser.parse()
    let isExpectedFailure = if case .failure(.invalidDirective) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseBlocklist(): process name nil text")
  func parseBlocklistProcessNameNilText() async throws {
    let parser = Parser(
      with: FakeLexer(tokens: [
        Token(type: .directive, text: ".blocklist"), Token(type: .beginList),
        Token(type: .string, text: nil), Token(type: .endList),
      ])
    )
    let result = parser.parse()
    let isExpectedFailure =
      if case .failure(.expectedStringLiteral) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseModifier(): opt alternative names")
  func parseWithOptAlternativeNames() async throws {
    let input = """
      opt - space: echo "opt space"
      lopt - a: echo "lopt a"
      ropt - 0x31: echo "ropt space hex"
      """

    let parser = Parser(with: input)
    let result = parser.parse()
    let configuration = try result.get()

    #expect(configuration.hotKeys.count == 3)
    #expect(configuration.blockList.isEmpty)

    #expect(configuration.hotKeys[0].key == kVK_Space)
    #expect(configuration.hotKeys[0].modifierFlags == .alt)
    #expect(configuration.hotKeys[0].command == "echo \"opt space\"")

    #expect(configuration.hotKeys[1].key == kVK_ANSI_A)
    #expect(configuration.hotKeys[1].modifierFlags == .lalt)
    #expect(configuration.hotKeys[1].command == "echo \"lopt a\"")

    #expect(configuration.hotKeys[2].key == kVK_Space)
    #expect(configuration.hotKeys[2].modifierFlags == .ralt)
    #expect(configuration.hotKeys[2].command == "echo \"ropt space hex\"")
  }

  @Test("parseModifier(): invalid modifier literal")
  func parseInvalidModifierLiteral() async throws {
    let parser = Parser(with: "ctrl + invalidmod - space: echo hello")
    let result = parser.parse()
    let isExpectedFailure =
      if case .failure(.invalidModifierLiteral) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseModifier(): nil text")
  func parseModifierNilText() async throws {
    let parser = Parser(with: FakeLexer(tokens: [Token(type: .modifier, text: nil)]))
    let result = parser.parse()
    let isExpectedFailure =
      if case .failure(.invalidModifierLiteral) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseKey(): invalid key")
  func parseInvalidKey() async throws {
    let parser = Parser(with: FakeLexer(tokens: [Token(type: .key, text: "invalid")]))
    let result = parser.parse()
    let isExpectedFailure = if case .failure(.invalidKey) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseKey(): nil text")
  func parseKeyNilText() async throws {
    let parser = Parser(with: FakeLexer(tokens: [Token(type: .key, text: nil)]))
    let result = parser.parse()
    let isExpectedFailure = if case .failure(.invalidKey) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseKeyHex(): invalid key hex")
  func parseInvalidKeyHex() async throws {
    let parser = Parser(with: "ctrl + shift - 0xGG: echo hello")
    let result = parser.parse()
    let isExpectedFailure = if case .failure(.invalidKeyHex) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseKeyHex(): nil text")
  func parseKeyHexNilText() async throws {
    let parser = Parser(with: FakeLexer(tokens: [Token(type: .keyHex, text: nil)]))
    let result = parser.parse()
    let isExpectedFailure = if case .failure(.invalidKeyHex) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseKeyLiteral(): invalid key literal during lexing")
  func parseInvalidKeyLiteralDuringLexing() async throws {
    let parser = Parser(with: "ctrl + shift - foo: echo hello")
    let result = parser.parse()
    let isExpectedFailure = if case .failure(.invalidKeyLiteral) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseKeyLiteral(): invalid key literal during parse")
  func parseInvalidKeyLiteralDuringParse() async throws {
    let parser = Parser(with: FakeLexer(tokens: [Token(type: .literal, text: "invalid")]))
    let result = parser.parse()
    let isExpectedFailure = if case .failure(.invalidKeyLiteral) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseKeyLiteral(): nil text")
  func parseKeyLiteralNilText() async throws {
    let parser = Parser(with: FakeLexer(tokens: [Token(type: .literal, text: nil)]))
    let result = parser.parse()
    let isExpectedFailure = if case .failure(.invalidKeyLiteral) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseCommand(): invalid command")
  func parseMissingCommandAfterColon() async throws {
    let parser = Parser(with: "ctrl + shift - a:")
    let result = parser.parse()
    let isExpectedFailure = if case .failure(.invalidCommand) = result { true } else { false }
    #expect(isExpectedFailure)
  }

  @Test("parseCommand(): nil text")
  func parseCommandNilText() async throws {
    let parser = Parser(
      with: FakeLexer(tokens: [Token(type: .key, text: "a"), Token(type: .command, text: nil)])
    )
    let result = parser.parse()
    let isExpectedFailure = if case .failure(.invalidCommand) = result { true } else { false }
    #expect(isExpectedFailure)
  }
}
