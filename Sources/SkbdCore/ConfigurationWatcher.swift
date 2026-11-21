import Darwin
import Dispatch
import Foundation

final class ConfigurationWatcher: @unchecked Sendable {
  private static let maxSymlinkHops = 32

  private let url: URL
  private let queue = DispatchQueue(label: "skbd.configuration-watcher")
  private let queueKey = DispatchSpecificKey<Void>()
  private let debounceInterval: DispatchTimeInterval
  private let onChange: @Sendable () -> Void

  private var sources: [DispatchSourceFileSystemObject] = []
  private var pendingChange: DispatchWorkItem?

  init(
    url: URL,
    debounceInterval: DispatchTimeInterval = .milliseconds(200),
    onChange: @escaping @Sendable () -> Void
  ) {
    self.url = url
    self.debounceInterval = debounceInterval
    self.onChange = onChange

    queue.setSpecific(key: queueKey, value: ())
  }

  deinit {
    stop()
  }

  func start() {
    queue.async { [weak self] in
      self?.rebuildSources()
    }
  }

  func stop() {
    // The last release can happen on the watcher queue, so deinit must not re-enter it.
    if DispatchQueue.getSpecific(key: queueKey) != nil {
      cancelPendingWork()
    } else {
      queue.sync(execute: cancelPendingWork)
    }
  }

  private func cancelPendingWork() {
    pendingChange?.cancel()
    pendingChange = nil

    cancelSources()
  }

  private func scheduleChange() {
    pendingChange?.cancel()

    let workItem = DispatchWorkItem { [weak self] in
      guard let self else { return }

      self.pendingChange = nil
      self.rebuildSources()

      let onChange = self.onChange

      DispatchQueue.main.async {
        onChange()
      }
    }

    pendingChange = workItem
    queue.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
  }

  private func rebuildSources() {
    cancelSources()

    for url in watchedURLs() {
      let descriptor = open(url.path, O_EVTONLY)

      guard descriptor >= 0 else { continue }

      let source = DispatchSource.makeFileSystemObjectSource(
        fileDescriptor: descriptor,
        eventMask: [.write, .delete, .rename, .attrib, .extend, .link, .revoke],
        queue: queue
      )

      source.setEventHandler { [weak self] in
        self?.scheduleChange()
      }

      source.setCancelHandler {
        close(descriptor)
      }

      sources.append(source)
      source.resume()
    }
  }

  private func cancelSources() {
    for source in sources {
      source.cancel()
    }

    sources.removeAll()
  }

  private func watchedURLs() -> [URL] {
    var urls: [URL] = []
    var current = url.standardizedFileURL

    // Follow symlinks one hop at a time so each link's directory stays watched, even when
    // its target is missing, and recreating the target triggers a rebuild.
    for _ in 0..<Self.maxSymlinkHops {
      urls.append(nearestExistingAncestor(of: current.deletingLastPathComponent()))

      guard
        let destination = try? FileManager.default.destinationOfSymbolicLink(atPath: current.path)
      else {
        break
      }

      current =
        URL(fileURLWithPath: destination, relativeTo: current.deletingLastPathComponent())
        .absoluteURL
        .standardizedFileURL
    }

    guard FileManager.default.fileExists(atPath: current.path) else {
      return unique(urls)
    }

    urls.append(current)

    let values = try? current.resourceValues(forKeys: [.isDirectoryKey])

    if values?.isDirectory == true {
      urls.append(contentsOf: (try? ConfigurationLoader.regularFiles(in: current)) ?? [])
    }

    return unique(urls)
  }

  // A removed directory cannot be watched, so watch the closest ancestor that still exists
  // and rebuild the more specific watches when the path is recreated.
  private func nearestExistingAncestor(of url: URL) -> URL {
    var current = url.standardizedFileURL

    while !FileManager.default.fileExists(atPath: current.path), current.path != "/" {
      current = current.deletingLastPathComponent()
    }

    return current
  }

  private func unique(_ urls: [URL]) -> [URL] {
    var seen = Set<String>()

    return urls.filter { seen.insert($0.standardizedFileURL.path).inserted }
  }
}
