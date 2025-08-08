import Foundation

public class ConfigManager {
  private var configPath: URL
  private var hotKeyManager: HotKeyShortcutManager

  private var directorySource: DispatchSourceFileSystemObject?
  private var fileSources: [DispatchSourceFileSystemObject] = []

  public init(configPath: URL, hotKeyManager: HotKeyShortcutManager) {
    self.configPath = configPath.resolvingSymlinksInPath()
    self.hotKeyManager = hotKeyManager
  }

  public func load() throws {
    hotKeyManager.reset()
    try parseConfig()
  }

  public func start() -> Bool {
    // TODO: setup monitoring file vs. directory
    // guard setupMonitoring() else { return false }

    return hotKeyManager.start()
  }

  public func stop() {
    hotKeyManager.stop()

    for source in fileSources {
      source.cancel()
    }

    fileSources.removeAll()
    directorySource?.cancel()
    directorySource = nil
  }

  private func parseConfig() throws {
    var isDirectory: ObjCBool = false

    guard FileManager.default.fileExists(atPath: configPath.path(), isDirectory: &isDirectory) else {
      throw ConfigError.configurationDoesNotExist
    }

    if isDirectory.boolValue {
      try parseConfigDirectory()
    } else {
      try parseConfig(file: configPath)
    }
  }

  private func parseConfigDirectory() throws {
    let files = try FileManager.default.contentsOfDirectory(
      at: configPath,
      includingPropertiesForKeys: nil,
      options: .skipsHiddenFiles
    )

    for file in files {
      try parseConfig(file: file)
    }
  }

  private func parseConfig(file: URL) throws {
    let config = try String(contentsOf: file.resolvingSymlinksInPath())
    let parser = Parser(config)
    let shortcuts = try parser.parse()

    for shortcut in shortcuts {
      if shortcut is LeaderShortcut {
        // TODO: handle leader shortcut
      } else if let modifierShortcut = shortcut as? ModifierShortcut {
        hotKeyManager.register(shortcut: modifierShortcut)
      } else if shortcut is SequenceShortcut {
        // TODO: handle sequence shortcuts
      }
    }
  }

  private func setupMonitoring() -> Bool {
    for source in fileSources {
      source.cancel()
    }

    fileSources.removeAll()

    do {
      let files = try FileManager.default.contentsOfDirectory(
        at: configPath,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: .skipsHiddenFiles
      )

      for file in files {
        guard setupFileMonitor(for: file.resolvingSymlinksInPath()) else {
          throw ConfigError.failedToMonitorConfigurationFile
        }
      }

      return setupDirectoryMonitor()
    } catch {
      fputs("failed to enumerate directory contexts: \(error)", stderr)
      fflush(stderr)

      return false
    }
  }

  private func setupDirectoryMonitor() -> Bool {
    let fd = open(configPath.path(), O_EVTONLY)
    guard fd != -1 else { return false }

    directorySource = DispatchSource.makeFileSystemObjectSource(
      fileDescriptor: fd,
      eventMask: [.write, .extend],
      queue: DispatchQueue(label: "dev.tombell.skbd.config.dir")
    )

    guard let directorySource = directorySource else { return false }

    directorySource.setEventHandler { [weak self] in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        _ = self?.setupMonitoring()
        self?.reloadConfiguration()
      }
    }

    directorySource.setCancelHandler {
      close(fd)
    }

    directorySource.resume()

    return true
  }

  private func setupFileMonitor(for file: URL) -> Bool {
    let fd = open(file.path(), O_EVTONLY)
    guard fd != -1 else { return false }

    let source = DispatchSource.makeFileSystemObjectSource(
      fileDescriptor: fd,
      eventMask: [.write, .rename, .delete],
      queue: DispatchQueue(label: "dev.tombell.skbd.config.file")
    )

    source.setEventHandler { [weak self] in
      self?.reloadConfiguration()
    }

    source.setCancelHandler {
      close(fd)
    }

    source.resume()
    fileSources.append(source)

    return true
  }

  private func reloadConfiguration() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      do {
        fputs("reloading configuration...\n", stdout)
        fflush(stdout)

        try self.load()
      } catch {
        fputs("failed to reload configuration: \(error)\n", stderr)
        fflush(stderr)
      }
    }
  }
}
