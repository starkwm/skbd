import Foundation
import Testing

@testable import SkbdCore

@Suite("ConfigurationLoader")
struct ConfigurationLoaderTests {
  @Test("load(from:): single file")
  func loadFile() throws {
    let directory = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }

    let file = directory.appendingPathComponent("skbdrc")

    try "cmd - a: echo file".write(to: file, atomically: true, encoding: .utf8)

    let result = try ConfigurationLoader.load(from: file)

    #expect(result == "cmd - a: echo file")
  }

  @Test("load(from:): symlinked file")
  func loadSymlinkFile() throws {
    let directory = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }

    let file = directory.appendingPathComponent("target-skbdrc")
    let link = directory.appendingPathComponent("skbdrc")

    try "cmd - a: echo symlink".write(to: file, atomically: true, encoding: .utf8)
    try FileManager.default.createSymbolicLink(at: link, withDestinationURL: file)

    let result = try ConfigurationLoader.load(from: link)

    #expect(result == "cmd - a: echo symlink")
  }

  @Test("load(from:): directory in lexicographical order")
  func loadDirectory() throws {
    let directory = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }

    let second = directory.appendingPathComponent("20-second")
    let first = directory.appendingPathComponent("10-first")
    let hidden = directory.appendingPathComponent(".ignored")
    let subdirectory = directory.appendingPathComponent("15-directory")

    try "cmd - b: echo second".write(to: second, atomically: true, encoding: .utf8)
    try "cmd - a: echo first".write(to: first, atomically: true, encoding: .utf8)
    try "should not load".write(to: hidden, atomically: true, encoding: .utf8)
    try FileManager.default.createDirectory(at: subdirectory, withIntermediateDirectories: true)

    let result = try ConfigurationLoader.load(from: directory)

    #expect(
      result
        == """
        cmd - a: echo first
        cmd - b: echo second
        """
    )
  }

  @Test("load(from:): symlinked directory matches the resolved directory")
  func loadSymlinkDirectory() throws {
    let root = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: root) }

    let directory = root.appendingPathComponent("fragments")
    let link = root.appendingPathComponent("skbd")

    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try "cmd - b: echo second".write(
      to: directory.appendingPathComponent("20-second"),
      atomically: true,
      encoding: .utf8
    )
    try "cmd - a: echo first".write(
      to: directory.appendingPathComponent("10-first"),
      atomically: true,
      encoding: .utf8
    )
    try FileManager.default.createSymbolicLink(at: link, withDestinationURL: directory)

    let direct = try ConfigurationLoader.load(from: directory)
    let linked = try ConfigurationLoader.load(from: link)

    #expect(direct == "cmd - a: echo first\ncmd - b: echo second")
    #expect(linked == direct)
  }

  @Test("load(from:): broken symlink reports a missing file")
  func loadBrokenSymlink() throws {
    let directory = try temporaryDirectory()
    defer { try? FileManager.default.removeItem(at: directory) }

    let link = directory.appendingPathComponent("skbdrc")

    try FileManager.default.createSymbolicLink(
      at: link,
      withDestinationURL: directory.appendingPathComponent("missing")
    )

    let error = #expect(throws: CocoaError.self) {
      try ConfigurationLoader.load(from: link)
    }

    #expect(error?.code == .fileReadNoSuchFile)
  }

  private func temporaryDirectory() throws -> URL {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)

    return url
  }
}
