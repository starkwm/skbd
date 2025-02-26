import Foundation

public class ConfigManager {
  private var shortcutManager: ShortcutManager

  private var configPath: URL

  public init(configPath: URL) {
    self.shortcutManager = ShortcutManager()
    self.configPath = configPath
  }

  deinit {
    self.shortcutManager.reset()
    self.shortcutManager.stop()
  }

  public func load() throws {
    shortcutManager.reset()

    try parseConfig(filePath: configPath)
  }

  public func start() -> Bool {
    return shortcutManager.start()
  }

  public func stop() {
    shortcutManager.stop()
  }

  private func parseConfig(filePath: URL) throws {
    var isDirectory: ObjCBool = false

    if !FileManager.default.fileExists(atPath: filePath.path, isDirectory: &isDirectory) {
      throw ConfigError.configurationDoesNotExist
    }

    if isDirectory.boolValue {
      try parseConfigDir(filePath: filePath)
    } else {
      try parseConfigFile(filePath: filePath)
    }
  }

  private func parseConfigDir(filePath: URL) throws {
    let files = try FileManager.default.contentsOfDirectory(
      at: filePath,
      includingPropertiesForKeys: nil,
      options: .skipsHiddenFiles
    )

    for file in files {
      try parseConfigFile(filePath: file)
    }
  }

  private func parseConfigFile(filePath: URL) throws {
    let config = try String(contentsOf: filePath)
    let parser = Parser(config)
    let shortcuts = try parser.parse()

    for shortcut in shortcuts {
      switch shortcut {
      case _ as LeaderShortcut:
        // TODO: handle leader shortcut
        continue
      case let modifierShortcut as ModifierShortcut:
        shortcutManager.register(shortcut: modifierShortcut)
      case _ as SequenceShortcut:
        // TODO: handle sequence shortcuts
        continue
      default:
        continue
      }
    }
  }
}
