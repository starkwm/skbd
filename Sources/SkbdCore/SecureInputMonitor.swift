import AppKit
import Carbon

// While any process has secure event input enabled, macOS stops delivering key presses to
// event taps, so shortcuts silently stop working. There is no notification when it changes,
// so poll for it and report each change.
public final class SecureInputMonitor: @unchecked Sendable {
  public enum State: Equatable {
    case disabled
    case enabled(processID: pid_t?, processName: String?)
  }

  private let interval: TimeInterval
  private let currentState: () -> State
  private let onChange: (String) -> Void
  private var lastState: State = .disabled
  private var timer: Timer?

  public init(
    interval: TimeInterval = 2,
    currentState: @escaping () -> State = SecureInputMonitor.systemState,
    onChange: @escaping (String) -> Void
  ) {
    self.interval = interval
    self.currentState = currentState
    self.onChange = onChange
  }

  deinit {
    timer?.invalidate()
  }

  public func start() {
    guard timer == nil else { return }

    check()

    let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
      self?.check()
    }

    RunLoop.main.add(timer, forMode: .common)
    self.timer = timer
  }

  func check() {
    let state = currentState()

    guard state != lastState else { return }

    lastState = state
    onChange(Self.message(for: state))
  }

  static func message(for state: State) -> String {
    switch state {
    case .disabled:
      return "secure input disabled, shortcuts are active again"
    case .enabled(let processID, let processName):
      let owner =
        switch (processName, processID) {
        case (let name?, let pid?): " by \(name) (pid \(pid))"
        case (nil, let pid?): " by pid \(pid)"
        case (let name?, nil): " by \(name)"
        case (nil, nil): ""
        }

      return "secure input enabled\(owner), shortcuts are blocked until it is turned off"
    }
  }

  public static func systemState() -> State {
    guard IsSecureEventInputEnabled() else { return .disabled }

    let session = CGSessionCopyCurrentDictionary() as? [String: Any]
    let processID = (session?["kCGSSessionSecureInputPID"] as? NSNumber)?.int32Value
    let processName = processID.flatMap {
      NSRunningApplication(processIdentifier: $0)?.localizedName
    }

    return .enabled(processID: processID, processName: processName)
  }
}
