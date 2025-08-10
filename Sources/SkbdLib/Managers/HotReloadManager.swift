import Foundation

public class HotReloadManager {
  private var directorySource: DispatchSourceFileSystemObject?
  private var fileSources: [DispatchSourceFileSystemObject] = []

  private var path: URL
  private var configManager: ConfigManager

  public init(path: URL, configManager: ConfigManager) {
    self.path = path
    self.configManager = configManager
  }

  public func start() throws -> Bool {
    stop()

    var isDirectory: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: path.path(), isDirectory: &isDirectory)

    guard exists else { throw HotReloadError.fileOrDirectoryDoesNotExist(path: path) }

    if isDirectory.boolValue {
      return try setup(directory: path)
    }

    return setup(file: path)
  }

  public func stop() {
    for source in fileSources {
      source.cancel()
    }

    fileSources.removeAll()

    directorySource?.cancel()
    directorySource = nil
  }

  private func setup(directory: URL) throws -> Bool {
    let files = try FileManager.default.contentsOfDirectory(
      at: directory.resolvingSymlinksInPath(),
      includingPropertiesForKeys: [.isRegularFileKey],
      options: .skipsHiddenFiles
    )

    for file in files {
      guard watch(file: file) else { throw HotReloadError.failedToWatchFileForChanges(path: file) }
    }

    return watch(directory: directory)
  }

  private func setup(file: URL) -> Bool {
    return watch(file: file)
  }

  private func watch(directory: URL) -> Bool {
    let fd = open(directory.path(), O_EVTONLY)
    guard fd != -1 else { return false }

    directorySource = DispatchSource.makeFileSystemObjectSource(
      fileDescriptor: fd,
      eventMask: [.write, .extend],
      queue: DispatchQueue(label: "dev.tombell.skbd.watch.directory")
    )

    guard let directorySource = directorySource else { return false }

    directorySource.setEventHandler { [weak self] in self?.restart() }
    directorySource.setCancelHandler { close(fd) }
    directorySource.resume()

    return true
  }

  private func watch(file: URL) -> Bool {
    let fd = open(file.resolvingSymlinksInPath().path(), O_EVTONLY)
    guard fd != -1 else { return false }

    let source = DispatchSource.makeFileSystemObjectSource(
      fileDescriptor: fd,
      eventMask: [.write, .rename, .delete],
      queue: DispatchQueue(label: "dev.tombell.skbd.watch.file")
    )

    source.setEventHandler { [weak self] in self?.reload() }
    source.setCancelHandler { close(fd) }
    source.resume()

    fileSources.append(source)

    return true
  }

  private func restart() {
    DispatchQueue.main.async {
      do {
        guard try self.start() else {
          fputs("failed to start hot reload manager on changes\n", stderr)
          fflush(stderr)
          return
        }

        self.reload()
      } catch {
        fputs("failed to restart hot reload manager on changes: \(error)\n", stderr)
        fflush(stderr)
      }
    }
  }

  private func reload() {
    DispatchQueue.main.async {
      do {
        fputs("reloading configuration...\n", stdout)
        fflush(stdout)
        try self.configManager.load()
      } catch {
        fputs("failed to reload configuration: \(error)\n", stderr)
        fflush(stderr)
      }
    }
  }
}
