import Foundation
import Testing

@testable import SkbdCore

@Suite("ConfigurationWatcher")
struct ConfigurationWatcherTests {
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

private enum WatcherTestError: Error {
  case descriptorsLeaked
}

private func openDescriptorCount() throws -> Int {
  try FileManager.default.contentsOfDirectory(atPath: "/dev/fd").count
}
