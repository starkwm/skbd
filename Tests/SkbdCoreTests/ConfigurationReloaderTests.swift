import Foundation
import Synchronization
import Testing

@testable import SkbdCore

@Suite("ConfigurationReloader")
struct ConfigurationReloaderTests {
  @Test("Loads bindings and the blocklist from disk")
  func loadConfiguration() throws {
    let file = URL.temporaryDirectory.appending(path: UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: file) }

    try """
    .blocklist ["Finder"]
    cmd - 0x31: echo space
    """.write(to: file, atomically: true, encoding: .utf8)

    let configuration = try ConfigurationReloader.load(from: file)

    #expect(configuration.blockList == ["Finder"])
    #expect(configuration.hotKeys.count == 1)
    let binding = try #require(configuration.hotKeys.first)
    #expect(binding.modifierFlags == .cmd)
    #expect(binding.key == 0x31)
    #expect(binding.command == "echo space")
  }

  @Test("A missing configuration reports a load failure")
  func missingFile() throws {
    let file = URL.temporaryDirectory.appending(path: UUID().uuidString)

    do {
      _ = try ConfigurationReloader.load(from: file)
      Issue.record("Loaded a missing configuration")
    } catch ConfigurationReloaderError.loadFailed(let cause as CocoaError) {
      #expect(cause.code == .fileReadNoSuchFile)
    }
  }

  @Test("A malformed configuration reports the parser failure")
  func malformedFile() throws {
    let file = URL.temporaryDirectory.appending(path: UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: file) }
    try "space:".write(to: file, atomically: true, encoding: .utf8)

    do {
      _ = try ConfigurationReloader.load(from: file)
      Issue.record("Loaded a malformed configuration")
    } catch ConfigurationReloaderError.parseFailed(let cause) {
      #expect(cause == .invalidCommand)
    }
  }

  @Test("Keeps the last valid binding after a bad edit and applies the correction")
  func recoverAfterBadEdit() async throws {
    let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: directory) }

    let file = directory.appending(path: "skbdrc")
    try "space: echo original".write(to: file, atomically: true, encoding: .utf8)
    let initial = try ConfigurationReloader.load(from: file)
    let applied = Mutex([initial.hotKeys.map(\.command)])
    let errors = Mutex<[String]>([])
    let reloader = ConfigurationReloader(
      url: file,
      onReload: { configuration in
        applied.withLock { $0.append(configuration.hotKeys.map(\.command)) }
      },
      onError: { message in errors.withLock { $0.append(message) } }
    )

    reloader.start()
    defer { withExtendedLifetime(reloader) {} }

    // Startup installs watches asynchronously. Retry the first edit if it preceded the watch.
    let deadline = ContinuousClock.now + .seconds(5)
    repeat {
      try "space:".write(to: file, atomically: true, encoding: .utf8)
      try await Task.sleep(for: .milliseconds(500))
    } while errors.withLock({ $0.isEmpty }) && ContinuousClock.now < deadline

    let diagnostic = "error parsing the configuration file: invalid command"
    let messages = errors.withLock { $0 }
    try #require(messages.contains(diagnostic))
    #expect(applied.withLock { $0 } == [["echo original"]])

    try "space: echo corrected".write(to: file, atomically: true, encoding: .utf8)
    let recoveryDeadline = ContinuousClock.now + .seconds(5)
    while applied.withLock({ $0.count == 1 }) && ContinuousClock.now < recoveryDeadline {
      try await Task.sleep(for: .milliseconds(20))
    }

    let updates = applied.withLock { Array($0.dropFirst()) }
    #expect(!updates.isEmpty)
    #expect(updates.allSatisfy { $0 == ["echo corrected"] })
  }
}
