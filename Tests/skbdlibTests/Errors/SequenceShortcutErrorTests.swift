import Testing

@testable import skbdlib

@Suite("SequenceShortcutError")
struct SequenceShortcutErrorTests {
  // MARK: - SequenceShortcutError#description

  @Test("SequenceShortcutError#description")
  func description() async throws {
    let tests: [SequenceShortcutError: String] = [
      .actionIsMissing: "sequence shortcut is missing an action"
    ]

    for (err, expected) in tests {
      #expect(err.description == expected)
    }
  }
}
