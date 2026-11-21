import Foundation
import Testing

@testable import SkbdCore

@Suite("ConfigurationWatcher")
struct ConfigurationWatcherTests {
  @Test("Recovers after a symlink target outside the link's directory is recreated")
  func recoverRecreatedSymlinkTarget() async throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }

    let configDirectory = root.appendingPathComponent("config")
    let targetDirectory = root.appendingPathComponent("targets")
    let link = configDirectory.appendingPathComponent("skbdrc")
    let target = targetDirectory.appendingPathComponent("skbdrc")

    try FileManager.default.createDirectory(at: configDirectory, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: targetDirectory, withIntermediateDirectories: true)
    try "cmd - a: echo a".write(to: target, atomically: true, encoding: .utf8)
    try FileManager.default.createSymbolicLink(at: link, withDestinationURL: target)

    let changes = ChangeCounter()
    let watcher = ConfigurationWatcher(url: link, debounceInterval: debounce) {
      changes.increment()
    }

    watcher.start()
    defer { watcher.stop() }

    try await changes.settle()

    try await changes.expectChange {
      try FileManager.default.removeItem(at: target)
    }

    try await changes.expectChange {
      try "cmd - b: echo b".write(to: target, atomically: true, encoding: .utf8)
    }

    try await changes.expectChange {
      try "cmd - c: echo c".write(to: target, atomically: false, encoding: .utf8)
    }
  }

  @Test("Recovers after the configuration's parent directory is recreated")
  func recoverRecreatedParentDirectory() async throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }

    let configDirectory = root.appendingPathComponent("config")
    let file = configDirectory.appendingPathComponent("skbdrc")

    try FileManager.default.createDirectory(at: configDirectory, withIntermediateDirectories: true)
    try "cmd - a: echo a".write(to: file, atomically: true, encoding: .utf8)

    let changes = ChangeCounter()
    let watcher = ConfigurationWatcher(url: file, debounceInterval: debounce) {
      changes.increment()
    }

    watcher.start()
    defer { watcher.stop() }

    try await changes.settle()

    try await changes.expectChange {
      try FileManager.default.removeItem(at: configDirectory)
    }

    try await changes.expectChange {
      try FileManager.default.createDirectory(
        at: configDirectory,
        withIntermediateDirectories: true
      )
      try "cmd - b: echo b".write(to: file, atomically: true, encoding: .utf8)
    }

    try await changes.expectChange {
      try "cmd - c: echo c".write(to: file, atomically: false, encoding: .utf8)
    }
  }

  @Test("Releasing a watcher right after start tears down without trapping")
  func releaseImmediatelyAfterStart() async {
    // A dispatch trap would end the test runner, so exercise teardown in a child process.
    await #expect(processExitsWith: .success) {
      let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
      let file = directory.appendingPathComponent("skbdrc")

      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      try "cmd - a: echo a".write(to: file, atomically: true, encoding: .utf8)
      defer { try? FileManager.default.removeItem(at: directory) }

      let baseline = try openDescriptorCount()

      for _ in 0..<500 {
        ConfigurationWatcher(url: file) {}.start()
      }

      for _ in 0..<100 {
        let watcher = ConfigurationWatcher(url: file) {}

        watcher.start()
        watcher.stop()
        watcher.start()
        watcher.stop()
      }

      let deadline = Date().addingTimeInterval(5)

      while try openDescriptorCount() > baseline {
        guard Date() < deadline else {
          throw WatcherTestError.descriptorsLeaked
        }

        try await Task.sleep(for: .milliseconds(20))
      }
    }
  }
}

private let debounce = DispatchTimeInterval.milliseconds(50)

private enum WatcherTestError: Error {
  case descriptorsLeaked
}

private final class ChangeCounter: @unchecked Sendable {
  private let lock = NSLock()
  private var value = 0

  var count: Int {
    lock.withLock { value }
  }

  func increment() {
    lock.withLock { value += 1 }
  }

  // Waits until no change has arrived for several debounce intervals.
  func settle() async throws {
    var last = count

    while true {
      try await Task.sleep(for: .milliseconds(200))

      let current = count

      if current == last { return }

      last = current
    }
  }

  func expectChange(
    sourceLocation: SourceLocation = #_sourceLocation,
    after action: () throws -> Void
  ) async throws {
    let baseline = count

    try action()

    let deadline = ContinuousClock.now + .seconds(3)

    while count == baseline, ContinuousClock.now < deadline {
      try await Task.sleep(for: .milliseconds(20))
    }

    #expect(count > baseline, "no reload after the change", sourceLocation: sourceLocation)

    try await settle()
  }
}

private func temporaryDirectory() throws -> URL {
  let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

  try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

  return url
}

private func openDescriptorCount() throws -> Int {
  try FileManager.default.contentsOfDirectory(atPath: "/dev/fd").count
}
