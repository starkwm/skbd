import AppKit
import SkbdLib

let hotKeyManager = HotKeyShortcutManager()
var configManager: ConfigManager!
var hotReloadManager: HotReloadManager!

@discardableResult
func printError(_ message: String) -> Int32 {
  fputs("\(message)\n", stderr)
  fflush(stderr)
  return EXIT_FAILURE
}

@discardableResult
func printInfo(_ message: String) -> Int32 {
  fputs("\(message)\n", stdout)
  fflush(stdout)
  return EXIT_SUCCESS
}

func setupLockFile() -> Bool {
  do {
    try LockFile.acquire()
    return true
  } catch {
    printError("failed to create lock file: \(error)")
    return false
  }
}

func loadConfiguration() -> Bool {
  configManager = ConfigManager(
    configPath: arguments.config,
    hotKeyManager: hotKeyManager
  )

  do {
    try configManager.load()
    return true
  } catch {
    printError("failed to load configuration: \(error)")
    return false
  }
}

func setupHotReload() -> Bool {
  hotReloadManager = HotReloadManager(
    path: arguments.config,
    configManager: configManager
  )

  do {
    guard try hotReloadManager.start() else {
      printError("failed to start hot reload manager")
      return false
    }

    return true
  } catch {
    printError("failed to start hot reload manager: \(error)")
    return false
  }
}

func setupSignalHandlers() {
  signal(SIGINT) { _ in
    printInfo("received SIGINT - terminating...")
    hotKeyManager.stop()
    exit(EXIT_SUCCESS)
  }
}

func main() -> Int32 {
  if arguments.version {
    return printInfo("skbd version \(Version.current.value)")
  }

  guard setupLockFile() else { return EXIT_FAILURE }
  guard loadConfiguration() else { return EXIT_FAILURE }
  guard setupHotReload() else { return EXIT_FAILURE }

  guard hotKeyManager.start() else {
    return printError("failed to start hot key manager")
  }

  setupSignalHandlers()

  NSApplication.shared.run()
  return EXIT_SUCCESS
}

exit(main())
