import AppKit
import skbdlib

var hotKeyManager: HotKeyShortcutManager!
var config: ConfigManager!

func main() -> Int32 {
  if arguments.version {
    fputs("skbd version \(Version.current.value)\n", stdout)
    fflush(stdout)
    return EXIT_SUCCESS
  }

  if arguments.reload {
    do {
      let pid = try LockFile.readPID()
      kill(pid, SIGUSR1)
      return EXIT_SUCCESS
    } catch {
      fputs("failed to read pid from lock file: \(error)\n", stderr)
      return EXIT_FAILURE
    }
  }

  do {
    try LockFile.acquire()
  } catch {
    fputs("failed to create lock file: \(error)\n", stderr)
    return EXIT_FAILURE
  }

  do {
    hotKeyManager = HotKeyShortcutManager()
    config = ConfigManager(configPath: arguments.config, hotKeyManager: hotKeyManager)

    try config.load()

    if !config.start() {
      fputs("failed to start configuration manager", stderr)
      return EXIT_FAILURE
    }
  } catch {
    fputs("failed to read configuration: \(error)\n", stderr)
    return EXIT_FAILURE
  }

  signal(SIGUSR1) { _ in
    do {
      fputs("received SIGUSR1 - reloading configuration...\n", stdout)
      fflush(stdout)

      try config.load()
    } catch {
      fputs("failed to reload configuration: \(error)\n", stderr)
    }
  }

  signal(SIGINT) { _ in
    fputs("received SIGINT - terminating...\n", stdout)
    fflush(stdout)

    config = nil
    exit(EXIT_SUCCESS)
  }

  NSApplication.shared.run()

  return EXIT_SUCCESS
}

exit(main())
