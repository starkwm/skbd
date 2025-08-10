import AppKit
import SkbdLib

let hotKeyManager = HotKeyShortcutManager()

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
      fflush(stderr)
      return EXIT_FAILURE
    }
  }

  do {
    try LockFile.acquire()
  } catch {
    fputs("failed to create lock file: \(error)\n", stderr)
    fflush(stderr)
    return EXIT_FAILURE
  }

  let configManager = ConfigManager(configPath: arguments.config, hotKeyManager: hotKeyManager)

  do {
    try configManager.load()
  } catch {
    fputs("failed to load configuration: \(error)\n", stderr)
    fflush(stderr)
    return EXIT_FAILURE
  }

  guard hotKeyManager.start() else {
    fputs("failed to start hot key manager", stderr)
    fflush(stderr)
    return EXIT_FAILURE
  }

  signal(SIGINT) { _ in
    fputs("received SIGINT - terminating...\n", stdout)
    fflush(stdout)

    hotKeyManager.stop()

    exit(EXIT_SUCCESS)
  }

  NSApplication.shared.run()

  return EXIT_SUCCESS
}

exit(main())
