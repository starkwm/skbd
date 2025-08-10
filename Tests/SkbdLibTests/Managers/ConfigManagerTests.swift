import Carbon
import Foundation
import Testing

@testable import SkbdLib

@Suite("ConfigManager", .serialized)
class ConfigManagerTests {
  // MARK: - ConfigManager#load

  @Test("ConfigManager#load (with config file)")
  func loadWithConfigFile() async throws {
    let config = try #require(Bundle.module.url(forResource: "Resources/Fixtures/skbdrc", withExtension: nil))

    #expect(throws: Never.self) {
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()
    }
  }

  @Test("ConfigManager#load (with empty config file)")
  func loadWithEmptyConfigFile() async throws {
    let config = try #require(Bundle.module.url(forResource: "Resources/Fixtures/skbdrc.empty", withExtension: nil))

    #expect(throws: Never.self) {
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()
    }
  }

  @Test("ConfigManager#load (with invalid config file)")
  func loadWithInvalidConfigFile() async throws {
    let config = try #require(Bundle.module.url(forResource: "Resources/Fixtures/skbdrc.invalid", withExtension: nil))

    #expect(throws: ParserError.self) {
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()
    }
  }

  @Test("ConfigManager#load (with config directory)")
  func loadWithConfigDirectory() async throws {
    let config = try #require(Bundle.module.url(forResource: "Resources/Fixtures/skbd", withExtension: nil))

    #expect(throws: Never.self) {
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()
    }
  }

  @Test("ConfigManager#load (with invalid config file in directory)")
  func loadWithInvalidConfigDirectory() async throws {
    let config = try #require(Bundle.module.url(forResource: "Resources/Fixtures/skbd.invalid", withExtension: nil))

    #expect(throws: ParserError.self) {
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()
    }
  }

  @Test("ConfigManager#load (with non-existient config path)")
  func loadWithNoConfigPath() async throws {
    let config = URL(fileURLWithPath: "/i/dont/exist")

    #expect(throws: ConfigError.fileOrDirectoryDoesNotExist(path: config)) {
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()
    }
  }
}
