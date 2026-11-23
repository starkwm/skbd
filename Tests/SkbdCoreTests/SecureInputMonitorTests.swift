import Testing

@testable import SkbdCore

@Suite("SecureInputMonitor")
struct SecureInputMonitorTests {
  final class Recorder {
    var states: [SecureInputMonitor.State]
    var messages: [String] = []

    init(_ states: [SecureInputMonitor.State]) {
      self.states = states
    }
  }

  private func run(_ states: [SecureInputMonitor.State]) -> [String] {
    let recorder = Recorder(states)
    let monitor = SecureInputMonitor(
      currentState: { recorder.states.removeFirst() },
      onChange: { recorder.messages.append($0) }
    )

    for _ in states { monitor.check() }

    return recorder.messages
  }

  @Test("reports nothing while secure input stays disabled")
  func staysDisabled() {
    #expect(run([.disabled, .disabled]).isEmpty)
  }

  @Test("reports each change once, naming the process that enabled it")
  func reportsChanges() {
    let helium = SecureInputMonitor.State.enabled(processID: 1712, processName: "Helium")

    let messages = run([helium, helium, .disabled, .disabled])

    #expect(
      messages == [
        "secure input enabled by Helium (pid 1712), shortcuts are blocked until it is turned off",
        "secure input disabled, shortcuts are active again",
      ]
    )
  }

  @Test("reports when a different process takes over secure input")
  func reportsNewOwner() {
    let messages = run([
      .enabled(processID: 1712, processName: "Helium"),
      .enabled(processID: 42, processName: nil),
    ])

    #expect(messages.count == 2)
    #expect(messages.last?.contains("by pid 42,") == true)
  }
}
