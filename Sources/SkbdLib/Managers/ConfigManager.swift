import Foundation

public class ConfigManager {
  private var configPath: URL
  private var hotKeyManager: HotKeyShortcutManager
  private var sequenceManager: SequenceShortcutManager

  public init(
    configPath: URL,
    hotKeyManager: HotKeyShortcutManager,
    sequenceManager: SequenceShortcutManager
  ) {
    self.configPath = configPath
    self.hotKeyManager = hotKeyManager
    self.sequenceManager = sequenceManager
  }

  deinit {
    hotKeyManager.stop()
    hotKeyManager.reset()
    sequenceManager.reset()
  }

  public func load() throws {
    hotKeyManager.reset()
    sequenceManager.reset()

    try parseConfig(filePath: configPath)
  }

  public func start() -> Bool {
    return hotKeyManager.start()
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
      if var leaderShortcut = shortcut as? LeaderShortcut {
        leaderShortcut.action = sequenceManager.listen
        hotKeyManager.register(shortcut: leaderShortcut)
      } else if let modifierShortcut = shortcut as? ModifierShortcut {
        hotKeyManager.register(shortcut: modifierShortcut)
      } else if let sequenceShortcut = shortcut as? SequenceShortcut {
        try sequenceManager.register(shortcut: sequenceShortcut)
      }
    }
  }
}
