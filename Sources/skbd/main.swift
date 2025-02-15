import AppKit
import skbdlib

let shortcutManager = ShortcutManager()

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
      fputs("error reading pid from lockfile: \(error)\n", stderr)
      return EXIT_FAILURE
    }
  }

  do {
    try LockFile.acquire()
  } catch {
    fputs("error creating lockfile file: \(error)\n", stderr)
    return EXIT_FAILURE
  }

  do {
    let config = try String(contentsOfFile: arguments.config)
    let parser = Parser(config)
    let shortcuts = try parser.parse()

    for shortcut in shortcuts {
      shortcutManager.register(shortcut: shortcut)
    }

    if !shortcutManager.start() {
      fputs("error starting the shortcut manager", stderr)
      return EXIT_FAILURE
    }
  } catch {
    fputs("error parsing configuration file: \(error)\n", stderr)
    return EXIT_FAILURE
  }

  signal(SIGUSR1) { _ in
    do {

      fputs("received SIGUSR1 - reloading configuration...\n", stdout)
      fflush(stdout)

      let config = try String(contentsOfFile: arguments.config)
      let parser = Parser(config)
      let shortcuts = try parser.parse()

      shortcutManager.reset()

      for shortcut in shortcuts {
        shortcutManager.register(shortcut: shortcut)
      }
    } catch {
      fputs("error parsing configuration file: \(error)\n", stderr)
    }
  }

  signal(SIGINT) { _ in
    fputs("received SIGINT - terminating...\n", stdout)
    fflush(stdout)
    shortcutManager.stop()
    exit(EXIT_SUCCESS)
  }

  NSApplication.shared.run()

  return EXIT_SUCCESS
}

exit(main())
