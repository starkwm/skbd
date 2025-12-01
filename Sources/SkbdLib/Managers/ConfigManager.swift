import Foundation

public class ConfigManager {
  private let configPath: URL
  private let hotKeyManager: HotKeyShortcutManager

  public init(configPath: URL, hotKeyManager: HotKeyShortcutManager) {
    self.configPath = configPath.resolvingSymlinksInPath()
    self.hotKeyManager = hotKeyManager
  }

  public func load() throws {
    hotKeyManager.reset()

    var isDirectory: ObjCBool = false

    let exists = FileManager.default.fileExists(
      atPath: configPath.path(),
      isDirectory: &isDirectory
    )
    guard exists else { throw ConfigError.fileOrDirectoryDoesNotExist(path: configPath) }

    if !isDirectory.boolValue {
      try parse(file: configPath)
      return
    }

    let files = try FileManager.default.contentsOfDirectory(
      at: configPath,
      includingPropertiesForKeys: nil,
      options: .skipsHiddenFiles
    )

    for file in files {
      try parse(file: file)
    }
  }

  private func parse(file: URL) throws {
    let config = try String(contentsOf: file.resolvingSymlinksInPath())
    let parser = Parser(config)
    let shortcuts = try parser.parse()

    for shortcut in shortcuts {
      guard let modifierShortcut = shortcut as? ModifierShortcut else { continue }
      hotKeyManager.register(shortcut: modifierShortcut)
    }
  }
}
