import Testing

@testable import skbdlib

@Suite("StringProtocol+Subscript")
struct StringProtocolSubscriptTests {
  // MARK: StringProtocol#subscript

  @Test("String[] (with indices)")
  func subscriptWithIndices() async throws {
    let str = "Hello world 😍"

    #expect(str[1] == "e")
    #expect(str[5] == " ")
    #expect(str[8] == "r")
    #expect(str[12] == "😍")
  }

  @Test("String[] (with range)")
  func subscriptWithRange() async throws {
    let str = "Hello world 🤦🏻‍♂️"

    #expect(str[0..<5] == "Hello")
    #expect(str[6..<11] == "world")
    #expect(str[12..<13] == "🤦🏻‍♂️")
  }
}
