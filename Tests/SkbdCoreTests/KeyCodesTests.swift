import Testing

@testable import SkbdCore

@Suite("KeyCodes")
struct KeyCodesTests {
  @Test("key(for:): unknown key code")
  func unknownCode() {
    let result = KeyCodes.key(for: 123_456_789)

    #expect(result == "unknown")
  }
}
