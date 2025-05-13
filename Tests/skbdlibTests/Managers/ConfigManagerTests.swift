import Carbon
import Foundation
import Testing

@testable import skbdlib

@Suite("ConfigManager")
class ConfigManagerTests {
  // MARK: - ConfigManager#read

  @Test("ConfigManager#read (with config file)")
  func readWithConfigFile() async throws {
    let config = try #require(Bundle.module.url(forResource: "Resources/Fixtures/skbdrc", withExtension: nil))

    #expect(throws: Never.self) {
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()
    }
  }

  @Test("ConfigManager#read (with empty config file)")
  func readWithEmptyConfigFile() async throws {
    let config = try #require(Bundle.module.url(forResource: "Resources/Fixtures/skbdrc.empty", withExtension: nil))

    #expect(throws: Never.self) {
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()
    }
  }

  @Test("ConfigManager#read (with invalid config file)")
  func readWithInvalidConfigFile() async throws {
    let config = try #require(Bundle.module.url(forResource: "Resources/Fixtures/skbdrc.invalid", withExtension: nil))

    #expect(throws: ParserError.self) {
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()
    }
  }

  @Test("ConfigManager#read (with config directory)")
  func readWithConfigDir() async throws {
    let config = try #require(Bundle.module.url(forResource: "Resources/Fixtures/skbd", withExtension: nil))

    #expect(throws: Never.self) {
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()
    }
  }

  @Test("ConfigManager#read (with invalid config file in directory)")
  func readWithInvalidConfigDir() async throws {
    let config = try #require(Bundle.module.url(forResource: "Resources/Fixtures/skbd.invalid", withExtension: nil))

    #expect(throws: ParserError.self) {
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()
    }
  }

  @Test("ConfigManager#read (with non-existient config path)")
  func readWithNoConfigPath() async throws {
    #expect(throws: ConfigError.configurationDoesNotExist) {
      let config = URL(fileURLWithPath: "/i/dont/exist")
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()
    }
  }

  // MARK: - ConfigManager#start

  @Test("ConfigManager#start (with shortcuts)")
  func startWithShortcuts() async throws {
    let config = try #require(Bundle.module.url(forResource: "Resources/Fixtures/skbdrc", withExtension: nil))

    #expect(throws: Never.self) {
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()

      #expect(configManager.start())
    }
  }

  @Test("ConfigManager#start (with no shortcuts)")
  func startWithNoShortcuts() async throws {
    let config = try #require(Bundle.module.url(forResource: "Resources/Fixtures/skbdrc.empty", withExtension: nil))

    #expect(throws: Never.self) {
      let configManager = ConfigManager(configPath: config, hotKeyManager: HotKeyShortcutManager())
      try configManager.load()

      #expect(configManager.start() == false)
    }
  }
}
