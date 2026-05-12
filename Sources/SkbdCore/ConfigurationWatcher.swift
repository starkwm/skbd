import Darwin
import Dispatch
import Foundation

final class ConfigurationWatcher: @unchecked Sendable {
  private let url: URL
  private let queue = DispatchQueue(label: "skbd.configuration-watcher")
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
  }

  deinit {
    stop()
  }

  func start() {
    queue.async {
      self.rebuildSources()
    }
  }

  func stop() {
    queue.sync {
      self.pendingChange?.cancel()
      self.pendingChange = nil
      self.cancelSources()
    }
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
    var urls = [url.deletingLastPathComponent().standardizedFileURL]
    let resolvedURL = url.resolvingSymlinksInPath().standardizedFileURL

    guard FileManager.default.fileExists(atPath: resolvedURL.path) else {
      return unique(urls)
    }

    do {
      let values = try resolvedURL.resourceValues(forKeys: [.isDirectoryKey])

      if values.isDirectory == true {
        urls.append(resolvedURL)
        urls.append(contentsOf: (try? ConfigurationLoader.regularFiles(in: resolvedURL)) ?? [])
      } else {
        urls.append(resolvedURL)
      }
    } catch {
      urls.append(resolvedURL)
    }

    return unique(urls)
  }

  private func unique(_ urls: [URL]) -> [URL] {
    var seen = Set<String>()
    var result: [URL] = []

    for url in urls {
      let path = url.standardizedFileURL.path
      guard seen.insert(path).inserted else { continue }
      result.append(url)
    }

    return result
  }
}
