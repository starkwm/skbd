import AppKit
import skbdlib

func main() -> Int32 {
  if arguments.version {
    fputs("skbd version \(Version.current.value)\n", stdout)
    return EXIT_SUCCESS
  }

  if arguments.reload {
    do {
      let pid = try LockFile.readPid()
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
      ShortcutManager.register(shortcut: shortcut)
    }

    if !ShortcutManager.start() {
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

      let config = try String(contentsOfFile: arguments.config)
      let parser = Parser(config)
      let shortcuts = try parser.parse()

      ShortcutManager.reset()

      for shortcut in shortcuts {
        ShortcutManager.register(shortcut: shortcut)
      }
    } catch {
      fputs("error parsing configuration file: \(error)\n", stderr)
    }
  }

  signal(SIGINT) { _ in
    fputs("received SIGINT - terminating...\n", stdout)
    ShortcutManager.stop()
    exit(EXIT_SUCCESS)
  }

  NSApplication.shared.run()

  return EXIT_SUCCESS
}

exit(main())
