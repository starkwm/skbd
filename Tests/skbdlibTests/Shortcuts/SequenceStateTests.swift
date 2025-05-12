import Testing

@testable import skbdlib

@Suite("SequenceState")
struct SequenceStateTests {
  // MARK: - SequenceState#currentGroup
  @Test("SequenceState#currentGroup (with initial group)")
  func currentGroup() async throws {
    let state = SequenceState()

    #expect(state.currentGroup == nil)
  }

  @Test("SequenceState#currentGroup (when navigated to new group)")
  func currentGroupWhenNavigatedToNewGroup() async throws {
    let group: [String: SequenceShortcutNode] = ["MyGroup": .action(key: "a", action: {})]
    let state = SequenceState()

    state.navigationTo(group: group)

    let currentGroup = try #require(state.currentGroup)
    #expect(currentGroup.count == 1)

    let node = try #require(currentGroup["MyGroup"])
    #expect(node.description == "Action {Key: a}")
  }

  // MARK: - SequenceState#reset
  @Test("SequenceState#reset")
  func reset() async throws {
    let group: [String: SequenceShortcutNode] = ["MyGroup": .action(key: "z", action: {})]
    let state = SequenceState()

    state.navigationTo(group: group)

    let currentGroup = try #require(state.currentGroup)
    #expect(currentGroup.count == 1)

    let node = try #require(currentGroup["MyGroup"])
    #expect(node.description == "Action {Key: z}")

    state.reset()

    #expect(state.currentGroup == nil)
  }

  // MARK: - SequenceState#navigateTo(group:)

  @Test("SequenceState#navigateTo(group:)")
  func navigateTo() async throws {
    let group: [String: SequenceShortcutNode] = [
      "a": .action(key: "a", action: {}),
      "b": .action(key: "b", action: {}),
    ]
    let state = SequenceState()

    state.navigationTo(group: group)

    let currentGroup = try #require(state.currentGroup)
    #expect(currentGroup.count == 2)

    let nodeA = try #require(currentGroup["a"])
    #expect(nodeA.description == "Action {Key: a}")

    let nodeB = try #require(currentGroup["b"])
    #expect(nodeB.description == "Action {Key: b}")
  }
}
