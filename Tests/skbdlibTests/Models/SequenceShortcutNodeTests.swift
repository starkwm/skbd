import Testing

@testable import skbdlib

@Suite("SequenceShortcutNode")
struct SequenceShortcutNodeTests {
  // MARK: - SequenceShortcutNode#descripion

  @Test("SequenceShortcutNode#description (with tree of nodes)")
  func description() async throws {
    let root: [SequenceShortcutNode] = [
      .action(key: "d", action: {}),
      .action(key: "e", action: {}),
      .group(
        key: "o",
        children: [
          "b": .group(
            key: "b",
            children: [
              "c": .action(key: "c", action: {}),
              "f": .action(key: "f", action: {}),
              "s": .action(key: "s", action: {}),
            ]
          )
        ]
      ),
      .action(key: "m", action: {}),
    ]

    let expected =
      "[Action {Key: d}, Action {Key: e}, Group {Key: o, Children: {Group {Key: b, Children: {Action {Key: c}, Action {Key: f}, Action {Key: s}}}}}, Action {Key: m}]"

    #expect(root.description == expected)
  }
}
